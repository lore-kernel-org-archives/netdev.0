From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH] ioatdma: fix "ioatdma frees DMA memory with wrong
	function"
Date: Tue, 12 May 2009 14:03:25 +0400
Message-ID: <a4423d670905120303y5dc8760fva244f62460cfd2c8@mail.gmail.com>
References: <20090423123128.31427.20238.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Maciej Sosnowski <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:47120 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbZELKD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 06:03:26 -0400
In-Reply-To: <20090423123128.31427.20238.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/4/23 Maciej Sosnowski <maciej.sosnowski@intel.com>:
> as reported by Alexander Beregalov <a.beregalov@gmail.com>
>
> ioatdma 0000:00:08.0: DMA-API: device driver frees DMA memory with
> wrong function [device address=0x000000007f76f800] [size=2000 bytes]
> [map
> ped as single] [unmapped as page]
>
> The ioatdma driver was unmapping all regions
> (either allocated as page or single) using unmap_page.
> This patch lets dma driver recognize if unmap_single or unmap_page should be used.
> It introduces two new dma control flags:
> DMA_COMPL_SRC_UNMAP_SINGLE and DMA_COMPL_DEST_UNMAP_SINGLE.
> They should be set to indicate dma driver to do dma-unmapping as single
> (first one for the source, tha latter for the destination).
> If respective flag is not set, the driver assumes dma-unmapping as page.
>
> Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
> Acked-by: Dan Williams <dan.j.williams@intel.com>
> Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
> Tested-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---

Will it be sent to Linus ?
