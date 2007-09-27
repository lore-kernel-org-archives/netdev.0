From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Thu, 27 Sep 2007 17:38:01 +1000
Message-ID: <1190878682.30275.9.camel@pasglop>
References: <20070908120036.GB8478@infradead.org>
	 <20070909061551G.tomof@acm.org>	<46F8C935.8050907@suse.de>
	 <20070925133624H.tomof@acm.org>  <46FB5C6B.3020506@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: FUJITA Tomonori <tomof@acm.org>, hare@suse.de,
	open-iscsi@googlegroups.com, hch@infradead.org,
	davem@davemloft.net, mchristi@redhat.com, netdev@vger.kernel.org,
	anilgv@broadcom.com, talm@broadcom.com, lusinsky@broadcom.com,
	uri@broadcom.com, fujita.tomonori@lab.ntt.co.jp
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52933 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbXI0Hik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 03:38:40 -0400
In-Reply-To: <46FB5C6B.3020506@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2007-09-27 at 03:31 -0400, Jeff Garzik wrote:
> A key problem I was hoping would be solved with your work here was
> the 
> elimination of that post dma_map_sg() split.
> 
> If I understood James and Ben correctly, one of the key problems was 
> always in communicating libata's segment boundary needs to the IOMMU
> layers?

Yup. If we can put some constraint in struct device that the dma mapping
code can then look at ... we also need to ensure that what's passed in
for DMA'ing already matches those constraints as well since no-iommu
platforms will basically just keep the dma table as-is.

Ben.


