From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 1/5] sis900 printk audit
Date: Sun, 23 Jan 2005 09:52:29 +0100
Message-ID: <20050123085229.GD31816@gateway.milesteg.arr>
References: <20050122214657.18649.66345@localhost.localdomain> <20050122222640.GB24461@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050122222640.GB24461@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 22, 2005 at 11:26:40PM +0100, Francois Romieu wrote:
> Daniele Venzano <webvenza@libero.it> :
> [...]
> > Index: sis900.c
> > ===================================================================
> > --- a/drivers/net/sis900.c	(revision 83)
> > +++ b/drivers/net/sis900.c	(revision 84)
> [...]
> > @@ -1906,8 +1918,22 @@
> >  	strcpy (info->bus_info, pci_name(sis_priv->pci_dev));
> >  }
> >  
> > +static u32 sis900_get_msglevel(struct net_device *net_dev)
> > +{
> > +	struct sis900_private *sis_priv = net_dev->priv;
> 
> s/net_dev->priv/netdev_priv/

I don't understand, what's wrong here ?
Is that a suggestion that I make some global variable or macro to avoid
repeating that declaration in almost every function of the driver ?

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
