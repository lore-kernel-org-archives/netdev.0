From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to
 zero after unmapping the address
Date: Fri, 19 Mar 2010 21:06:55 -0700 (PDT)
Message-ID: <20100319.210655.183028527.davem@davemloft.net>
References: <20100319144132.10528.79305.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751007Ab0CTEGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 00:06:32 -0400
In-Reply-To: <20100319144132.10528.79305.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Mar 2010 07:41:33 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> As per Simon Horman's feedback set IXGBE_RSC_CB(skb)->dma to zero
> after unmapping HWRSC DMA address to avoid double freeing.
> 
> Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
