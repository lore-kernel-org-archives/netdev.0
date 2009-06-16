From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] vxge: Enable SRIOV support in the driver.
Date: Tue, 16 Jun 2009 02:33:04 -0700 (PDT)
Message-ID: <20090616.023304.56372168.davem@davemloft.net>
References: <Pine.GSO.4.10.10906160521210.13320-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com,
	santosh.rastapur@neterion.com, ram.vepa@neterion.com
To: Sivakumar.Subramani@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37286
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752096AbZFPJdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:33:01 -0400
In-Reply-To: <Pine.GSO.4.10.10906160521210.13320-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Date: Tue, 16 Jun 2009 05:26:09 -0400 (EDT)

> +#ifdef CONFIG_PCI_IOV
> +	pci_disable_sriov(pdev);
> +#endif

Toss these ifdefs.

These intefaces have NOP versions declared when the define
is not set.
