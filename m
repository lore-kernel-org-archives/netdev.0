From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Use bool flag to see if the
 packet unmapping is delayed in HWRSC
Date: Thu, 13 May 2010 21:09:23 -0700 (PDT)
Message-ID: <20100513.210923.68131492.davem@davemloft.net>
References: <20100514033233.30716.30144.stgit@localhost.localdomain>
	<20100514033319.30716.22999.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750865Ab0ENEJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 00:09:15 -0400
In-Reply-To: <20100514033319.30716.22999.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 May 2010 20:33:21 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> We can't use zero magic "bad" value to check if IXGBE_RSC_CB(skb)->dma
> is valid. It is only valid in x86/arm/m68k/alpha architectures and in
> spark, powerPC and other architectures it should be ~0. As per
> Benjamin Herrenschmidt feedback use a bool flag to decide if
> the packet unmapping is delayed in hardware RSC till EOP is reached
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
