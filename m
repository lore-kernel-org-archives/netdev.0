From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: fix r6040_multicast_list
Date: Wed, 07 Apr 2010 16:51:09 -0700 (PDT)
Message-ID: <20100407.165109.212914225.davem@davemloft.net>
References: <201004071318.48883.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darkadept@hispeed.ch
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831Ab0DGXvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 19:51:08 -0400
In-Reply-To: <201004071318.48883.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 7 Apr 2010 13:18:48 +0200

> As reported in <https://bugzilla.kernel.org/show_bug.cgi?id=15355>, r6040_
> multicast_list currently crashes. This is due a wrong maximum of multicast
> entries. This patch fixes the following issues with multicast:
> 
> - number of maximum entries if off-by-one (4 instead of 3)
> 
> - the writing of the hash table index is not necessary and leads to invalid
> values being written into the MCR1 register, so the MAC is simply put in a non
> coherent state
> 
> - when we exceed the maximum number of mutlticast address, writing the
> broadcast address should be done in registers MID_1{L,M,H} instead of
> MID_O{L,M,H}, otherwise we would loose the adapter's MAC address
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks Florian.
