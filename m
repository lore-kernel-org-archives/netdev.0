From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 12 Nov 2003 15:43:51 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112154351.A2415@infradead.org>
References: <3FB03A56.7000709@sgi.com> <20031110182911.2c5a121b.davem@redhat.com> <3FB140E2.1070007@sgi.com> <20031111122403.2d7bcf28.davem@redhat.com> <3FB15725.4050705@sgi.com> <20031111235330.GA25553@wotan.suse.de> <3FB190FE.20005@sgi.com> <20031112061958.GA12065@wotan.suse.de> <3FB1DBBF.1010403@pobox.com> <3FB2528E.9020605@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andi Kleen <ak@suse.de>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com, jes@sgi.com,
        David Mosberger <davidm@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: John Partridge <johnip@sgi.com>
Content-Disposition: inline
In-Reply-To: <3FB2528E.9020605@sgi.com>; from johnip@sgi.com on Wed, Nov 12, 2003 at 09:32:30AM -0600
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> --- linux/arch/ia64/Kconfig     2003-10-25 13:44:46.000000000 -0500
> +++ patch/arch/ia64/Kconfig     2003-11-12 09:31:14.000000000 -0600
> @@ -468,6 +468,10 @@
>            agent" (/sbin/hotplug) to load modules and set up software needed
>            to use devices as you hotplug them.
> 
> +config UNALIGNED_EXPENSIVE

> +       depends on IA64

this line is not needed - if you're in the ia64 Kconfig it's always set.
