From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Thu, 9 Apr 2015 17:57:57 +0100
Message-ID: <21798.44949.156680.399387@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
	<21796.7755.270785.292996@mariner.uk.xensource.com>
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1428448976.4720.15.camel@prashant>
	<21797.13348.524963.29127@mariner.uk.xensource.com>
	<1428543798.4720.20.camel@prashant>
	<21798.24161.922394.539733@mariner.uk.xensource.com>
	<1428595851.4720.22.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25050 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbbDIRFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 13:05:08 -0400
In-Reply-To: <1428595851.4720.22.camel@prashant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant Sreedharan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> On Thu, 2015-04-09 at 12:11 +0100, Ian Jackson wrote:
> > No.  I can try to repro the problem without the bridge, if it would
> > help.
> yes please do

I will do so.

FYI, when I came back to this test box just now (after leaving it
since yesterday) and now it is completely broken:

[89210.340696] DMA: Out of SW-IOMMU space for 1600 bytes at device 0000:03:00.0
[89210.449936] tg3 0000:03:00.0: swiotlb buffer is full (sz: 1600 bytes)

The root fs block device is also unuseable and gives lots of EIO.

This is with 3.14.21, baremetal, with `iommu=soft swiotlb=force'.

Ian.
