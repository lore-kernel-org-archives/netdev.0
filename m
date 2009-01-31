From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and
 private channels
Date: Sat, 31 Jan 2009 21:18:02 +0900 (JST)
Message-ID: <20090131.211802.75185523.anemo@mba.ocn.ne.jp>
References: <20090131.020300.82352947.anemo@mba.ocn.ne.jp>
	<e9c3a7c20901301513v74953d7aj8533d05cddfa510@mail.gmail.com>
	<Pine.LNX.4.64.0901310026200.4617@axis700.grange>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, maciej.sosnowski@intel.com,
	hskinnemoen@atmel.com, nicolas.ferre@atmel.com
To: g.liakhovetski@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:55173 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbZAaMSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 07:18:01 -0500
In-Reply-To: <Pine.LNX.4.64.0901310026200.4617@axis700.grange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Jan 2009 00:27:48 +0100 (CET), Guennadi Liakhovetski <g.liakhovetski@gmx.de> wrote:
> > Register multiple dma_devices, the public one with a DMA_MEMCPY, and
> > the fixed role devices with DMA_PRIVATE, DMA_MEMCPY, and DMA_SLAVE
> > capabilities.
> > 
> > DMA_PRIVATE ensures that a channel is never considered for public consumption.
> 
> Maybe just two dma-devices would suffice: one with the public memcpy 
> channel, and one with the rest private slave channels?

Thank you, I will try this.

---
Atsushi Nemoto
