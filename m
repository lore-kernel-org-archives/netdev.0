From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712
 devices)
Date: Wed, 01 Dec 2010 12:40:07 -0800 (PST)
Message-ID: <20101201.124007.116381672.davem@davemloft.net>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757000Ab0LAUjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:39:40 -0500
In-Reply-To: <1290982177.6066.3.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 29 Nov 2010 00:09:37 +0200

> NIC partitioning is another flavor of multi function - having few
> PCI functions share the same physical port. Unlike the currently
> supported mode of multi-function which depends on the switch
> configuration and uses outer-VLAN, the NPAR mode is switch independent
> and uses the MAC addresses to distribute incoming packets to the different
> functions. This patch adds the specific HW setting of the NPAR mode
> and some distinctions between switch dependent (SD) and
> switch independent (SI) multi-function (MF) modes where the configuration
> is not the same.
> 
> Advance driver version to 1.60.00-6
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied to net-next-2.6, but I expect you to keep discussing the
naming and sysfs issues with Matt Domsch. :-)
