From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Mon, 17 Aug 2009 16:25:06 +0200
Message-ID: <20090817142506.GB3602@elte.hu>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:49901 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755AbZHQOZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2009 10:25:26 -0400
Content-Disposition: inline
In-Reply-To: <4A8954F0.3040402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Gregory Haskins <gregory.haskins@gmail.com> wrote:

> Ingo Molnar wrote:
> > * Gregory Haskins <ghaskins@novell.com> wrote:
> > 
> >> This will generally be used for hypervisors to publish any host-side
> >> virtual devices up to a guest.  The guest will have the opportunity
> >> to consume any devices present on the vbus-proxy as if they were
> >> platform devices, similar to existing buses like PCI.
> >>
> >> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
> >> ---
> >>
> >>  MAINTAINERS                 |    6 ++
> >>  arch/x86/Kconfig            |    2 +
> >>  drivers/Makefile            |    1 
> >>  drivers/vbus/Kconfig        |   14 ++++
> >>  drivers/vbus/Makefile       |    3 +
> >>  drivers/vbus/bus-proxy.c    |  152 +++++++++++++++++++++++++++++++++++++++++++
> >>  include/linux/vbus_driver.h |   73 +++++++++++++++++++++
> >>  7 files changed, 251 insertions(+), 0 deletions(-)
> >>  create mode 100644 drivers/vbus/Kconfig
> >>  create mode 100644 drivers/vbus/Makefile
> >>  create mode 100644 drivers/vbus/bus-proxy.c
> >>  create mode 100644 include/linux/vbus_driver.h
> > 
> > Is there a consensus on this with the KVM folks? (i've added the KVM 
> > list to the Cc:)
> > 
> > 
> 
> Hi Ingo,
> 
> Avi can correct me if I am wrong, but the agreement that he and I 
> came to a few months ago was something to the effect of:
> 
> kvm will be neutral towards various external IO subsystems, and 
> instead provide various hooks (see irqfd, ioeventfd) to permit 
> these IO subsystems to interface with kvm.
> 
> AlacrityVM is one of the first projects to take advantage of that 
> interface.  AlacrityVM is kvm-core + vbus-core + 
> vbus-kvm-connector + vbus-enhanced qemu + guest drivers.  This 
> thread is part of the guest-drivers portion.  Note that it is 
> specific to alacrityvm, not kvm, which is why the kvm list was not 
> included in the conversation (also an agreement with Avi: 
> http://lkml.org/lkml/2009/8/6/231).

Well my own opinion is that the fracturing of the Linux internal 
driver space into diverging pieces of duplicate functionality 
(absent compelling technical reasons) is harmful.

	Ingo
