From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [v2 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 17:17:21 +0800
Message-ID: <20160919091721.GA12235@gondor.apana.org.au>
References: <20160804071846.GA773@gondor.apana.org.au>
 <20160804074546.GA996@gondor.apana.org.au>
 <1470377813.2977.14.camel@sipsolutions.net>
 <20160805104858.GA9297@gondor.apana.org.au>
 <1470394233.2977.37.camel@sipsolutions.net>
 <20160918135030.GA7062@gondor.apana.org.au>
 <20160919084056.GA11875@gondor.apana.org.au>
 <1474276530.4469.16.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1474276530.4469.16.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 11:15:30AM +0200, Johannes Berg wrote:
> On Mon, 2016-09-19 at 16:40 +0800, Herbert Xu wrote:
> 
> > I've tested the rhlist code with test_rhashtable but I haven't
> > tested the mac80211 conversion.  So please give it a go and see
> > if it still works.
> 
> This is still running out of memory on my test suite.
> 
> Somehow I don't see kmemleak kicking in, so I'll have to find the bug
> manually :)

What does your test suite actually do? Is it something that I
can run without special hardware?

Thanks,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
