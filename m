From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: blackhole route should always be recalculated
Date: Wed, 08 Sep 2010 14:36:55 -0700 (PDT)
Message-ID: <20100908.143655.68120451.davem@davemloft.net>
References: <4C77DE1C.4080506@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755694Ab0IHVgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:36:38 -0400
In-Reply-To: <4C77DE1C.4080506@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 27 Aug 2010 17:47:40 +0200

>>From 1683b838a42429af30d6ab76d2d15d267c93c455 Mon Sep 17 00:00:00 2001
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri, 27 Aug 2010 17:22:17 +0200
> Subject: [PATCH] net: blackhole route should always be recalculated
> 
> Blackhole routes are used when xfrm_lookup() returns -EREMOTE (error
> triggered by IKE for example), hence this kind of route is always
> temporary and so we should check if a better route exists for next
> packets.
> Bug has been introduced by commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92.
> 
> Signed-off-by: Jianzhao Wang <jianzhao.wang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks!
