From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Build error v3.9-rc when CONFIG_IPV6 configured as module
Date: Mon, 15 Apr 2013 20:12:28 +0200
Message-ID: <1366049548.8361.35.camel@jlt4.sipsolutions.net>
References: <1366016535.8361.2.camel@jlt4.sipsolutions.net>
	 <1366016677.8361.3.camel@jlt4.sipsolutions.net>
	 <1366016729.8361.4.camel@jlt4.sipsolutions.net>
	 <20130415.133059.752889111702097790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tomas.melin@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:50330 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755092Ab3DOSMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:12:37 -0400
In-Reply-To: <20130415.133059.752889111702097790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 13:30 -0400, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Mon, 15 Apr 2013 11:05:29 +0200
> 
> > On Mon, 2013-04-15 at 11:04 +0200, Johannes Berg wrote:
> > 
> >> > Oops, I didn't realize that IPv6 could even (still) be built as a
> >> > module. I'll add this to mac80211's Kconfig:
> >> >    depends on IPV6 || !IPV6
> >> > to fix this.
> >> 
> >> Hm, actually, that's not sufficient since there are no no-op versions of
> >> these functions when IPv6 isn't built ... needs a bit more.
> > 
> > Oh, never mind, I already handle that case ... Should check the code
> > before :)
> 
> Johannes, we already fixed this, see 'net'.  Don't add more hacks to
> mac80211.

Alright, thanks! Sorry for the noise, I wasn't aware of the other patch
until Tomas pointed it out.

johannes
