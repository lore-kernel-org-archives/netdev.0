From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/8] vxge: Fixed MSIX interrupt
 configuration.
Date: Mon, 29 Mar 2010 16:59:59 -0700 (PDT)
Message-ID: <20100329.165959.209731446.davem@davemloft.net>
References: <Pine.GSO.4.10.11003290410360.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754540Ab0C2X76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 19:59:58 -0400
In-Reply-To: <Pine.GSO.4.10.11003290410360.4435-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 29 Mar 2010 04:11:41 -0400 (EDT)

> - Fixed MSIX interrupt configuration to support non contiguous vpaths in
>   functions. Four msi-x vectors are reserved per vpath internal to the chip.
>   In all, there are 68 msi-x vectors for the 17 vpaths in the chip. In the 
>   multi function configurations, non-contiguous vpaths are configured to
>   represent a function. For instance vpaths 0 and 8 can be configured to
>   represent function zero.
> 
> - If pci_enable_msix fails for the requested vectors, try with a lesser number
>   vectors by reducing the vpath count.
>  
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

Applied.
