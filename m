From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/10] tg3: Use NET_IP_ALIGN
Date: Fri, 21 Nov 2008 17:16:25 -0800 (PST)
Message-ID: <20081121.171625.143644175.davem@davemloft.net>
References: <1227295575.5612@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57952
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753879AbYKVBQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:16:26 -0500
In-Reply-To: <1227295575.5612@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 21 Nov 2008 10:59:42 -0800

> This patch replaces hardcoded 2's with the NET_IP_ALIGN constant or
> TG3_RAW_IP_ALIGN where appropriate.  Some platforms can redefine the
> NET_IP_ALIGN definition to zero if unaligned DMA transfers cost more
> than the IP header alignment gains.  This patch represents a
> performance improvement when using the 5701 on these platforms.
> The copy path can be avoided.
> 
> TG3_RAW_IP_ALIGN is used in cases where we always want to align the
> IP header on dword boundaries.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
