From: Ramon Casellas <casellas@infres.enst.fr>
Subject: Re: Request: Allocate a Netlink Family Number for MPLS
Date: Mon, 1 Dec 2003 20:26:30 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SOL.4.40.0312012012040.27322-100000@gervaise.enst.fr>
References: <20031201153052.A3879@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20031201153052.A3879@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Dec 2003, Christoph Hellwig wrote:

> On Mon, Dec 01, 2003 at 03:36:26PM +0100, Ramon Casellas wrote:
> >  #define NETLINK_ARPD           8
> > +
> > +#if defined(CONFIG_MPLS) || defined(CONFIG_MPLS_MODULE)
> > +#define NETLINK_MPLS           9
> > +#endif
> > +
>
> This is bogus - either it's reserved or not, so the ifdef doesn't
> make sense.

Yes of course :) that was just a cut&paste from an interim patch, where we
put ifdefs around everything. If you decide to allocate a family number,
then ifdefs don't make sense (much like in if_ether.h or ppp_defs.h), but
you're right, my mistake, I didn't mean to propose a real patch.


>
> Also given that Dave & co are working on mpls already I wonder
> whether it's a good idea to reserve this, but I'll let him speak
> for himself :)

Well, we are still coordinating efforts, and Jamal has some design docs
around... but regardless of the actual implementation, a mechanism to
communicate with userspace will be needed, and IM(Very, very)HO, netlink
is a good candidate, analog to rtnetlink, but this is open to discussion.

Thanks,
R.
