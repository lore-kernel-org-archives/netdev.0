From: "Ramkrishna Vepa" <Ramkrishna.Vepa@exar.com>
Subject: RE: [net-next-2.6 PATCH 3/8] vxge: Align the memory only if it is misaligned.
Date: Mon, 29 Mar 2010 20:04:43 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77064C43D7@nekter>
References: <Pine.GSO.4.10.11003290409080.4435-100000@guinness> <20100329.165945.157920838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "David Miller" <davem@davemloft.net>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:51314 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754540Ab0C3AT6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 20:19:58 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100329.165945.157920838.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
> Date: Mon, 29 Mar 2010 04:09:47 -0400 (EDT)
> 
> > - Align the memory only if it is misaligned.
> >
> > Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> 
> Applied, but this vxge_os_dma_malloc code is completely
> unnecessary.
> 
> If you want to allocate 4K chunks and make sure they are at least 128
> byte aligned, you can allocated pages (which are always PAGE_SIZE
> aligned) and chop them up into the appropriate block size as needed.
> 
> This is exactly how drivers/net/niu.c handles this situation.
> 
> See drivers/net/niu.c:niu_rbr_add_page()
Thanks. We'll make this change.

Ram
