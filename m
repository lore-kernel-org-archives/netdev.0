From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ll_temac: fix interrupt bug when interrupt 0
 is used
Date: Wed, 26 May 2010 20:44:46 -0700 (PDT)
Message-ID: <20100526.204446.229736739.davem@davemloft.net>
References: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	brian.hill@xilinx.com
To: john.linn@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57488
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756992Ab0E0Doj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 23:44:39 -0400
In-Reply-To: <6f264a7a-e5da-494a-a24d-1578ca422807@VA3EHSMHS016.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Linn <john.linn@xilinx.com>
Date: Wed, 26 May 2010 11:29:18 -0600

> The code is not checking the interrupt for DMA correctly so that an
> interrupt number of 0 will cause a false error.
> 
> Signed-off-by: Brian Hill <brian.hill@xilinx.com>
> Signed-off-by: John Linn <john.linn@xilinx.com>

Applied.
