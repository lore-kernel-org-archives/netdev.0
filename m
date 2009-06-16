From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH net-next-2.6] vxge: Enable SRIOV support in the driver.
Date: Tue, 16 Jun 2009 13:57:05 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77056403DA@nekter>
References: <Pine.GSO.4.10.10906160521210.13320-100000@guinness> <20090616.023304.56372168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:54626 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979AbZFPR5E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 13:57:04 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090616.023304.56372168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will fix and resubmit the patch again.

Thanks,
~Siva

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, June 16, 2009 3:03 PM
To: Sivakumar Subramani
Cc: netdev@vger.kernel.org; support; Rastapur Santosh; Ramkrishna Vepa
Subject: Re: [PATCH net-next-2.6] vxge: Enable SRIOV support in the
driver.

From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Date: Tue, 16 Jun 2009 05:26:09 -0400 (EDT)

> +#ifdef CONFIG_PCI_IOV
> +	pci_disable_sriov(pdev);
> +#endif

Toss these ifdefs.

These intefaces have NOP versions declared when the define
is not set.
