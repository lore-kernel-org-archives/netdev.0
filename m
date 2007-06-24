From: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
Subject: Re: [RFC] [PATCH 2.6.21.5] ppp: fix osize too small errors when
	decoding mppe
Date: Mon, 25 Jun 2007 10:38:41 +1100
Message-ID: <1182728324.8980.17.camel@traveler>
References: <4679116E.9050507@gmail.com>
	 <20070623.230702.60547745.davem@davemloft.net>
Reply-To: konstantin.sharlaimov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, vsu@altlinux.ru, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:10427 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbXFXXjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 19:39:21 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1599425wah
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2007 16:39:21 -0700 (PDT)
In-Reply-To: <20070623.230702.60547745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-06-23 at 23:07 -0700, David Miller wrote:

The original version of this fix have made it to the 2.6.22-rc5 already
and should be replaced with this one, however the two can coexist in the
same code for a while.

> > --- linux-2.6.21.3/drivers/net/ppp_generic.c.orig	2007-06-20 09:14:13.000000000
> > +1100
> > +++ linux-2.6.21.3/drivers/net/ppp_generic.c	2007-06-20 09:18:06.000000000 +1100
> 
> Please prevent your email client from corrupting patches like
> this by adding new lines.

Also, thank you for pointing this issue out, I'll fix it.

