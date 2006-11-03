From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New stuff in wireless-dev, wireless developers please pull...
Date: Fri, 03 Nov 2006 12:16:30 +0100
Message-ID: <1162552590.2923.42.camel@ux156>
References: <20061103043024.GF2989@tuxdriver.com>
	 <200611030142.09303.flamingice@sourmilk.net>
	 <1162543492.2923.6.camel@ux156>  <1162544782.2923.15.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:20437 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1753224AbWKCLPb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 06:15:31 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <1162544782.2923.15.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-03 at 10:06 +0100, Johannes Berg wrote:
> > It doesn't seem to compile on my system:
> > 
> > net/built-in.o: In function `iw_send_thrspy_event':
> > wext-old.c:(.text+0x67672): undefined reference to `wireless_send_event'
> 
> Uh, common is missing. Adjust net/wireless/Makefile like this:

Alright, I've uploaded a proper patch for this and fixed up all my other
patches to apply against the current wireless-dev.

johannes
