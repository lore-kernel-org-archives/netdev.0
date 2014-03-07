From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: rfc: checkpatch logical line continuations (was IBM Akebono: Add
 support for a new PHY interface to the IBM emac driver)
Date: Sat, 8 Mar 2014 02:04:21 +0300
Message-ID: <20140307230420.GH29018@mwanda>
References: <1394077948-8395-1-git-send-email-alistair@popple.id.au>
 <1394077948-8395-3-git-send-email-alistair@popple.id.au>
 <20140307.154142.488351276799532264.davem@davemloft.net>
 <1394226164.16156.96.camel@joe-AO722>
 <20140307213017.GA18769@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140307213017.GA18769@cloud>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 07, 2014 at 01:30:17PM -0800, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org wrote:
> On Fri, Mar 07, 2014 at 01:02:44PM -0800, Joe Perches wrote:
> > On Fri, 2014-03-07 at 15:41 -0500, David Miller wrote:
> > > From: Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
> > > Date: Thu,  6 Mar 2014 14:52:25 +1100
> > > 
> > > > +	out_be32(dev->reg, in_be32(dev->reg) | WKUP_ETH_RGMIIEN
> > > > +		 | WKUP_ETH_TX_OE | WKUP_ETH_RX_IE);
> > > 
> > > When an expression spans multiple lines, the lines should end with
> > > operators rather than begin with them.
> > 
> > That's not in CodingStyle currently.
> 
> It's also not even remotely consistent across existing kernel code, and
> it isn't obvious that there's a general developer consensus on the
> "right" way to write it.
> 

We just had this discussion in staging and Greg modified the patch to
put the operator at the end.

https://lkml.org/lkml/2014/2/25/125

It's like logical && and || operators which go at the end these days.
I don't really want to have a lot of checkpatch churn to convert
everything...

regards,
dan carpenter

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
