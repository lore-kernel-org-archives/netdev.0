From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: Other alloc/OOM message question
Date: Fri, 8 Feb 2013 16:46:44 -0800
Message-ID: <20130209004644.GC31290@kroah.com>
References: <1360273587.27863.15.camel@joe-AO722>
 <20130208.174500.1518593039138341685.davem@davemloft.net>
 <1360369799.13487.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1360369799.13487.5.camel@joe-AO722>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 08, 2013 at 04:29:59PM -0800, Joe Perches wrote:
> On Fri, 2013-02-08 at 17:45 -0500, David Miller wrote:
> > From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> > Date: Thu, 07 Feb 2013 13:46:27 -0800
> > > alloc failures already get standardized OOM
> > > messages and a dump_stack.
> 
> Does anyone know if all the other alloc's like
> dma_alloc_coherent, dma_alloc_noncoherent,
> pci_alloc_consistent always produce OOM messages
> via page_alloc/warn_alloc_failed for all arches?

If not, they should, to allow this type of cleanups.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
