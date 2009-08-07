From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] mlx4_en: Using real number of rings
 as RSS map size
Date: Thu, 06 Aug 2009 19:28:30 -0700 (PDT)
Message-ID: <20090806.192830.196540620.davem@davemloft.net>
References: <4A631A7C.7090504@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755639AbZHGC2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 22:28:21 -0400
In-Reply-To: <4A631A7C.7090504@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Sun, 19 Jul 2009 16:07:08 +0300

> There is no point in using more QPs then actual number of receive rings.
> If the RSS function for two streams gives the same result modulo number
> of rings, they will arrive to the same RX ring anyway.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
