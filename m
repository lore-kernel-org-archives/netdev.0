From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Wed, 14 Jun 2006 22:47:20 +0200
Message-ID: <20060614204720.GA17887@electric-eye.fr.zoreil.com>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:16365 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932283AbWFNUta
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 16:49:30 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060614181419.GA10365@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Grundler <grundler@parisc-linux.org> :
[...]
> I'm not keen on adding more code to tulip_interrupt() routine
> for something that rarely happens (compared to IRQs) and is handled
> outside the interrupt routine.  I'm pretty sure stopping interrupts
> before stopping DMA is sufficient.
> Can you show an example where it doesn't work?

Shared irq. 

The device has not quiesced, the kernel stop listening to it and the
neighbor device receives a late interruption from the network device.

-- 
Ueimor
