From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: MSI interrupts and disable_irq
Date: Mon, 15 Oct 2007 07:47:53 +1000
Message-ID: <1192398473.6188.10.camel@pasglop>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com>
	 <4710901F.8010206@colorfullife.com>
	 <86802c440710132259o6e82f6s4bed7b25bd5636e9@mail.gmail.com>
	 <4711C217.2010605@colorfullife.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yhlu.kernel@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	nedev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41355 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134AbXJNVsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Oct 2007 17:48:14 -0400
In-Reply-To: <4711C217.2010605@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sun, 2007-10-14 at 09:15 +0200, Manfred Spraul wrote:
> Yinghai Lu wrote:
> > On 10/13/07, Manfred Spraul <manfred@colorfullife.com> wrote:
> >   
> >> Someone around with a MSI capable board? The forcedeth driver does
> >>     dev->irq = pci_dev->irq
> >> in nv_probe(), especially before pci_enable_msi().
> >> Does pci_enable_msi() change pci_dev->irq? Then we would disable the
> >> wrong interrupt....
> >>     
> >
> > the request_irq==>setup_irq will make dev->irq = pci_dev->irq.
> >
> >   
> Where is that?
> Otherwise I would propose the attached patch. My board is not 
> MSI-capable, thus I can't test it myself.

Why not just copy pcidev->irq to dev->irq once ?

Ben.


