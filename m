From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Fri, 16 May 2008 12:01:48 +1000
Message-ID: <200805161201.48835.rusty@rustcorp.com.au>
References: <20080507130548.GA26977@gondor.apana.org.au> <20080508032208.GA401@gondor.apana.org.au> <20080507.202606.242037993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080507.202606.242037993.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 08 May 2008 13:26:06 David Miller wrote:
> From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> Date: Thu, 8 May 2008 11:22:08 +0800
>
> > On Wed, May 07, 2008 at 03:48:06PM +0200, Michael Buesch wrote:
> > > So there's no way to actually fail in a TX handler? Drivers
> > > are doomed to drop the packet, if they cannot handle it due to
> > > ring overflow?
> >
> > You're supposed to stop the queue before the ring overflows.
>
> Right, and this is why drivers choose a TX wakeup threshold such
> that they can accept an arbitrarily sized TSO frame.

Dave, please allow me to ask a heretical question.  Returning TX_BUSY has some 
appeal for virtio_net: is it fundamentally a flawed idea, or simply a matter 
of coding?

Currently we have no virtio interface to ask how many descriptors are left; 
it's not clear that it's a fair question to ask, since for Xen it's depends 
on the actual buffers we're trying to put in the descirptors.

Thanks,
Rusty.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
