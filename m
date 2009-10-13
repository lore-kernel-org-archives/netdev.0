From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] x25: bit and/or confusion in x25_ioctl()?
Date: Tue, 13 Oct 2009 03:47:24 -0700 (PDT)
Message-ID: <20091013.034724.44299172.davem@davemloft.net>
References: <4ACC749E.4060806@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49904
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759440AbZJMKr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:47:28 -0400
In-Reply-To: <4ACC749E.4060806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 07 Oct 2009 12:59:42 +0200

> Looking at commit ebc3f64b864f it appears that this was intended
> and not the original, equivalent to `if (facilities.reverse & ~0x81)'.
> 
> In x25_parse_facilities() that patch changed how facilities->reverse
> was set. No other bits were set than 0x80 and/or 0x01.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Looks good to me, applied to net-next-2.6
