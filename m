From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [BUG] drivers/net/ioc3_eth.c in 2.5
Date: Wed, 11 Jun 2003 13:50:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611115055.GB26751@linux-mips.org>
References: <20030606161658.1f01b8f9.shemminger@osdl.org> <20030607.013010.116359540.davem@redhat.com> <20030609101018.0ca2e1f9.shemminger@osdl.org> <20030609171224.GA14623@gtf.org> <20030609110855.2e264ce1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030609110855.2e264ce1.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 11:08:55AM -0700, Stephen Hemminger wrote:

> Okay:
> --- ioc3-eth.c.orig	2003-06-09 10:05:45.000000000 -0700
> +++ ioc3-eth.c	2003-06-09 11:08:01.000000000 -0700
> @@ -1613,6 +1613,7 @@ static void __devexit ioc3_remove_one (s
>  	struct ioc3_private *ip = dev->priv;
>  	struct ioc3 *ioc3 = ip->regs;
>  
> +	unregister_netdev(dev);
>  	iounmap(ioc3);
>  	pci_release_regions(pdev);
>  	kfree(dev);

Thanks, applied.  Same is also needed for 2.4.

  Ralf
