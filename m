From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] div64_64 support
Date: Mon, 26 Feb 2007 16:07:08 -0800
Message-ID: <20070226160708.3c7a8d29@freekitty>
References: <20070223170527.4ca695b2@freekitty>
	<Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
	<20070226143127.5c74bec9@freekitty>
	<Pine.LNX.4.61.0702262348140.23355@yvahk01.tjqt.qr>
	<20070226154413.4ead571a@freekitty>
	<Pine.LNX.4.61.0702270103060.23355@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39211 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161454AbXB0AHP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 19:07:15 -0500
In-Reply-To: <Pine.LNX.4.61.0702270103060.23355@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Feb 2007 01:05:26 +0100 (MET)
Jan Engelhardt <jengelh@linux01.gwdg.de> wrote:

> 
> On Feb 26 2007 15:44, Stephen Hemminger wrote:
> >> >-		x = (2 * x + (uint32_t) div64_64(a, x*x)) / 3;
> >> >+		x = (2 * x + (u32) (a / x*x)) / 3;
> >> 
> >> Previously there was div64_64(a, x*x) which is equivalent to
> >> (a)/(x*x), or just: a/(x^2). But now you do a/x*x, which is
> >> equivalent to a*x/x (in the domain of real numbers). Furthermore,
> >> a/x*x is a-(a%x), which does not even remotely match a/(x^2).
> >> 
> >Been there, done that, don't want to repeat it...
> 
> I am sorry I don't quite follow.

Once before a missed paren's caused a TCP congestion window bug that
took 6 months before it was found...

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
