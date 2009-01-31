From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 01:44:16 +0100
Message-ID: <20090131004416.GC13709@elte.hu>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310059.17746.rjw@sisk.pl> <alpine.DEB.2.00.0901301924550.5056@parag-desktop> <200901310138.51214.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:50247 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258AbZAaAof (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 19:44:35 -0500
Content-Disposition: inline
In-Reply-To: <200901310138.51214.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Rafael J. Wysocki <rjw@sisk.pl> wrote:

> +static struct dev_pm_ops pcie_portdrv_pm_ops = {
> +	.suspend = pcie_port_device_suspend,
> +	.resume = pcie_port_device_resume,
> +	.freeze = pcie_port_device_suspend,
> +	.thaw = pcie_port_device_resume,
> +	.poweroff = pcie_port_device_suspend,
> +	.restore = pcie_port_device_resume,
> +};

pet peeve: could we please use vertical spaces wherever they improve the 
code?

Something like:

static struct dev_pm_ops pcie_portdrv_pm_ops = {
	.suspend	= pcie_port_device_suspend,
	.resume		= pcie_port_device_resume,
	.freeze		= pcie_port_device_suspend,
	.thaw		= pcie_port_device_resume,
	.poweroff	= pcie_port_device_suspend,
	.restore	= pcie_port_device_resume,
};

... and it all becomes clear at a glance. Please?

	Ingo
