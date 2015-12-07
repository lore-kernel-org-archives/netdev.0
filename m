From: Christian Zigotzky <chzigotzky@xenosoft.de>
Subject: [P.A. Semi] Does the ethernet interface work on your Electra, Chitra,
 Nemo, and Athena board?
Date: Mon, 7 Dec 2015 15:12:08 +0100
Message-ID: <566593B8.3070904@xenosoft.de>
References: <565AF986.9060106@xenosoft.de>
 <CAOJe8K1911vDjMe9m_1vY6DSGpOk0TmL96Qf1whuNFXxHJesGw@mail.gmail.com>
 <565C1B55.4020207@xenosoft.de> <565C8287.7090209@xenosoft.de>
 <20151130181217.GA15921@visitor2.iram.es> <565DB2FE.1010706@xenosoft.de>
 <565E7A9E.4000909@xenosoft.de> <1449044072.24750.3.camel@ellerman.id.au>
 <565F5E7C.9040207@xenosoft.de> <56603787.3000802@xenosoft.de>
 <566576E8.2060300@xenosoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>,
	Gabriel Paubert <paubert@iram.es>, netdev@vger.kernel.org,
	Denis Kirjanov <kda@linux-powerpc.org>,
	linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:24371 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932399AbbLGON1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 09:13:27 -0500
In-Reply-To: <566576E8.2060300@xenosoft.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have some good news for you. I was able to fix the issue with the P.A. 
Semi Ethernet. It was a problem with the new DMA handling. The patch ' 
[RFC/PATCH,v2] powerpc/iommu: Support "hybrid" iommu/direct DMA ops for 
coherent_mask < dma_mask (https://patchwork.ozlabs.org/patch/472535/)' 
is the problem.

I had patched the following files before I compiled a kernel.

arch/powerpc/Kconfig
arch/powerpc/include/asm/device.h
arch/powerpc/include/asm/dma-mapping.h
arch/powerpc/include/asm/iommu.h
arch/powerpc/kernel/dma-iommu.c
arch/powerpc/kernel/dma-swiotlb.c
arch/powerpc/kernel/dma.c
arch/powerpc/platforms/powernv/pci-ioda.c
arch/powerpc/platforms/pseries/iommu.c
arch/powerpc/sysdev/dart_iommu.c
include/asm-generic/dma-mapping-common.h

The P.A. Semi Ethernet works again with the patched kernel.

I am happy. :-)

Please fix the issue in the kernel source code.

Thanks in advance,

Christian
