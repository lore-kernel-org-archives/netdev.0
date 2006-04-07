From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH 17/21] orinoco_pci: use pci_iomap() for resources
Date: Fri, 07 Apr 2006 18:21:57 -0400
Message-ID: <1144448517.5618.14.camel@dv>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
	 <20060407081053.16107.19347.stgit@dv.roinet.com>
	 <20060407213619.GB15720@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
In-Reply-To: <20060407213619.GB15720-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-07 at 23:36 +0200, Francois Romieu wrote:

> > @@ -208,8 +205,8 @@ static int orinoco_pci_init_one(struct p
> >  	priv = netdev_priv(dev);
> >  	card = priv->card;
> >  	card->pci_ioaddr = pci_ioaddr;
> > -	dev->mem_start = pci_iorange;
> > -	dev->mem_end = pci_iorange + pci_iolen - 1;
> > +	dev->mem_start = pci_resource_start(pdev, 0);
> > +	dev->mem_end = dev->mem_start + pci_resource_len(pdev, 0) - 1;
> 
> Is there a reason why dev->mem_{start/end} should not be removed ?

Is there a reason why it should?  Is it going to be obsolete?

-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
