From: Michael Buesch <mb@bu3sch.de>
Subject: Re: ssb: Fix DMA-API compilation for non-PCI systems
Date: Mon, 10 Nov 2008 23:07:37 +0100
Message-ID: <200811102307.37838.mb@bu3sch.de>
References: <20081110.135231.96349017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:46208 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750973AbYKJWIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 17:08:24 -0500
In-Reply-To: <20081110.135231.96349017.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 November 2008 22:52:31 David Miller wrote:
> 
> I applied this since it's a build buster and we should
> get it fixed quickly.
> 
> But as I look at this, the thing to really do here is get
> rid of these stupid switch statements.  None of it is needed.
> 
> The layer that sets up the SSB devices should simply save the
> generic device pointer for the DMA entity into some new
> ->dma_dev struct member.
>
> Then you just use generic dma_*() interfaces unilaterally.  For PCI
> devices it will "just work".

We tried that. It doesn't work. It breaks on several architectures
that do special things in the pci_dma... functions.
See the git history and mailinglists, please.

-- 
Greetings Michael.
