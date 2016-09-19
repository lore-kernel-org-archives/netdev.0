From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [v2 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 12:58:37 +0200
Message-ID: <1474282717.4469.33.camel@sipsolutions.net>
References: <20160919084056.GA11875@gondor.apana.org.au>
         <1474276530.4469.16.camel@sipsolutions.net>
         <20160919091721.GA12235@gondor.apana.org.au>
         <1474277244.4469.21.camel@sipsolutions.net>
         <20160919093434.GA12378@gondor.apana.org.au>
         <1474278634.4469.25.camel@sipsolutions.net>
         <1474278896.4469.26.camel@sipsolutions.net>
         <1474279330.4469.28.camel@sipsolutions.net>
         <1474279492.4469.29.camel@sipsolutions.net>
         <1474279827.4469.30.camel@sipsolutions.net>
         <20160919104801.GA12774@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160919104801.GA12774-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-19 at 18:48 +0800, Herbert Xu wrote:
> On Mon, Sep 19, 2016 at 12:10:27PM +0200, Johannes Berg wrote:
> > 
> > Btw, for debug I put
> > 
> > BUG_ON(atomic_read(&ht->nelems) < 0);
> > 
> > after the atomic_dec() in __rhashtable_remove_fast_one(). That
> > makes
> > the kernel crash instantly on the buggy code, and I just have to
> > run a
> > single test ("wpas_ctrl_interface_add_many") to get there.
> 
> Aha I see the problem now.  The nelems logic on remove is broken.

I looked at it for a long time, but didn't see it :) But yeah, I've
come to the same conclusion by adding debugging of the chains etc.

> I'll send out a v3.

I'll test it when I have it :)

johannes
