From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vxge: Enable SRIOV support n the driver.
Date: Wed, 17 Jun 2009 04:32:45 -0700 (PDT)
Message-ID: <20090617.043245.88359322.davem@davemloft.net>
References: <Pine.GSO.4.10.10906170047300.6160-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com,
	ram.vepa@neterion.com, santosh.rastapur@neterion.com
To: Sivakumar.Subramani@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933109AbZFQLcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 07:32:42 -0400
In-Reply-To: <Pine.GSO.4.10.10906170047300.6160-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Date: Wed, 17 Jun 2009 00:48:55 -0400 (EDT)

> - Enabled SRIOV support in the driver.
> - Call __vxge_hw_verify_pci_e_info() for the PF only. This function
>   verifies the negotiated link width and current link speed in the
>   Link Status Register (offset 12h) which are reserved fields for VFs
>   as per the SRIOV specification, section 3.5.8.
> - Implemented David Miller's comment to remove the #ifdef CONFIG_PCI_IOV as 
>   these intefaces have NOP versions declared when the defintion is not set.
> 
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

Applied.
