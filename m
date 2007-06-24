From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH 2.6.21.5] ppp: fix osize too small errors when
 decoding mppe
Date: Sat, 23 Jun 2007 23:07:02 -0700 (PDT)
Message-ID: <20070623.230702.60547745.davem@davemloft.net>
References: <4679116E.9050507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, vsu@altlinux.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: konstantin.sharlaimov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34804
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753133AbXFXGGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 02:06:44 -0400
In-Reply-To: <4679116E.9050507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
Date: Wed, 20 Jun 2007 22:37:18 +1100

> The mppe_decompress() function required a buffer that is 1 byte too small when
> receiving a message of mru size. This fixes buffer allocation to prevent this
> from occurring.
> 
> Signed-off-by: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>

This looks better, I've reverted the original version of the
fix and applied this new one.

> --- linux-2.6.21.3/drivers/net/ppp_generic.c.orig	2007-06-20 09:14:13.000000000
> +1100
> +++ linux-2.6.21.3/drivers/net/ppp_generic.c	2007-06-20 09:18:06.000000000 +1100

Please prevent your email client from corrupting patches like
this by adding new lines.

I've fixed up your patches by hand now twice, I'm not going to do it
any more.

Thanks.
