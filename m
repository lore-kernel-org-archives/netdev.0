From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH] bnx2x: use the dma state API instead of the pci
 equivalents
Date: Sun, 4 Apr 2010 02:15:52 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDC@SJEXCHCCR02.corp.ad.broadcom.com>
References: <20100402115054A.fujita.tomonori@lab.ntt.co.jp>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDB@SJEXCHCCR02.corp.ad.broadcom.com>
 <20100404.013920.120463402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4878 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752675Ab0DDJQK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 05:16:10 -0400
In-Reply-To: <20100404.013920.120463402.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the changes in a PCI-DMA-mapping.txt it sounds like the trend is to stop using the pci_dma_* API and start using the dma_* API instead. Does this mean that using the pci_dma_* API is deprecated?

Thanks,
vlad

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Sunday, April 04, 2010 11:39 AM
> To: Vladislav Zolotarov
> Cc: fujita.tomonori@lab.ntt.co.jp; netdev@vger.kernel.org; 
> Eilon Greenstein
> Subject: Re: [PATCH] bnx2x: use the dma state API instead of 
> the pci equivalents
> 
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Sun, 4 Apr 2010 01:19:07 -0700
> 
> > So, if we don't need to use pci_X() interface anymore, lets replace
> > pci_X() properly all over the bnx2x with dma_X() functions.
> 
> I think Fujita's plan of gradual and partial transformations is
> legitimate, and his changes shouldn't be rejected because he simply
> isn't modifying all of the interfaces used by this driver but rather
> just a specific subset he is trying to transform across the tree.
> 
> Please rescind your objections.
> 
> Thanks.
> 
> 
