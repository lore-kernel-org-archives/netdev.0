From: Dave Dillow <dave@thedillows.org>
Subject: Re: [RFC 2.6.10 1/22] xfrm: Add direction information to xfrm_state
Date: Thu, 30 Dec 2004 11:21:27 -0500
Message-ID: <1104423687.23254.15.camel@dillow.idleaire.com>
References: <20041230035000.01@ori.thedillows.org>
	 <20041230035000.10@ori.thedillows.org>
	 <200412301436.06653.ioe-lkml@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Oeser <ioe-lkml@axxeo.de>
In-Reply-To: <200412301436.06653.ioe-lkml@axxeo.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[readding netdev to the cc list]

On Thu, 2004-12-30 at 08:36, Ingo Oeser wrote:
> Hi David,
> 
> I'm happy to see a framework and example driver for this.

Thanks, I'm just glad it works.

> David Dillow schrieb:
> > diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
> > --- a/include/net/xfrm.h 2004-12-30 01:12:08 -05:00
> > +++ b/include/net/xfrm.h 2004-12-30 01:12:08 -05:00
> > @@ -194,6 +203,7 @@
> >   struct xfrm_state *(*find_acq)(u8 mode, u32 reqid, u8 proto,
> >            xfrm_address_t *daddr, xfrm_address_t *saddr,
> >            int create);
> > + void   (*map_direction)(struct xfrm_state *xfrm);
> >  };
> >
> 
> Please don't build modifiers, but build functions instead.
> 
> e.g. 
> 
> xfrm->direction = map_direction(xfrm)
> 
> That way you don't hide the assignment and thus code becomes much clearer and
> can be called multiple times without risk.

I'll make the change for the next iteration.
-- 
Dave Dillow <dave@thedillows.org>
