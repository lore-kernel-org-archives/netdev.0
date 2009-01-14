From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 06:39:09 +0000
Message-ID: <20090114063909.GA4234@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <20081010095129.GB6054@ff.dom.local> <48F6FB3E.7060903@bigtelecom.ru> <20081016084027.GA17632@ff.dom.local> <48FEC302.5090707@bigtelecom.ru> <20081022070200.GB4178@ff.dom.local> <493FDCD4.5020108@bigtelecom.ru> <20081218081737.GA8416@ff.dom.local> <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Chris Caputo <ccaputo@alt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:55376 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbZANGjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 01:39:15 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:43:13AM +0000, Chris Caputo wrote:
...
> Per Jarek's suggestion in bugzilla, I ran 2.6.28 plus Peter Zijlstra's 
> "hrtimer: removing all ur callback modes" patches dated 2008-11-25, 
> 2008-12-04 and 2008-12-08.  Uptime was 2 days 22 hours before I hit what 
> appears to be an unrelated bug related to the IPv6 FIB.  (Separately 
> reported with subject 'panic with 2.6.28 while doing "ip -6 route"'.)

Chris, this is a very good news, thanks for testing this!

Peter, great work! IMHO these patches should go to the stable (at
least 2.6.28).

Thanks,
Jarek P.
