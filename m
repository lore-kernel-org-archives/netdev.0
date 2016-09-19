From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [v2 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 11:38:09 +0200
Message-ID: <1474277889.4469.24.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
         <20160804074546.GA996@gondor.apana.org.au>
         <1470377813.2977.14.camel@sipsolutions.net>
         <20160805104858.GA9297@gondor.apana.org.au>
         <1470394233.2977.37.camel@sipsolutions.net>
         <20160918135030.GA7062@gondor.apana.org.au>
         <20160919084056.GA11875@gondor.apana.org.au>
         <1474276530.4469.16.camel@sipsolutions.net>
         <20160919091721.GA12235@gondor.apana.org.au>
         <1474277244.4469.21.camel@sipsolutions.net>
         <20160919093434.GA12378@gondor.apana.org.au>
         (sfid-20160919_113440_719977_971CE718)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160919093434.GA12378-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org> (sfid-20160919_113440_719977_971CE718)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-19 at 17:34 +0800, Herbert Xu wrote:
> On Mon, Sep 19, 2016 at 11:27:24AM +0200, Johannes Berg wrote:
> > 
> > 
> > I have a feeling there's a bug with ht->nelems, since the crash is
> > always in the grow worker, but I haven't quite put my finger on it
> > yet.
> 
> Can you show me a stack trace?

Oops, just deleted the old ones to reproduce with some debug printks :)

It's always while trying to grow a table from the worker; it kills
processes, but eventually no process are left and the kernel panics.

I'll send you a trace when I have one again - I'm running a new
reproduction now.

johannes
