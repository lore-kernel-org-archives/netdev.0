From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Sat, 15 Aug 2009 12:32:43 +0200
Message-ID: <20090815103243.GA26749@elte.hu>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090814154308.26116.46980.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Gregory Haskins <ghaskins@novell.com> wrote:

> This will generally be used for hypervisors to publish any host-side
> virtual devices up to a guest.  The guest will have the opportunity
> to consume any devices present on the vbus-proxy as if they were
> platform devices, similar to existing buses like PCI.
> 
> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
> ---
> 
>  MAINTAINERS                 |    6 ++
>  arch/x86/Kconfig            |    2 +
>  drivers/Makefile            |    1 
>  drivers/vbus/Kconfig        |   14 ++++
>  drivers/vbus/Makefile       |    3 +
>  drivers/vbus/bus-proxy.c    |  152 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/vbus_driver.h |   73 +++++++++++++++++++++
>  7 files changed, 251 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/vbus/Kconfig
>  create mode 100644 drivers/vbus/Makefile
>  create mode 100644 drivers/vbus/bus-proxy.c
>  create mode 100644 include/linux/vbus_driver.h

Is there a consensus on this with the KVM folks? (i've added the KVM 
list to the Cc:)

	Ingo
