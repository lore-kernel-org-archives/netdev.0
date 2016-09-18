From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: [PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Sun, 18 Sep 2016 21:50:30 +0800
Message-ID: <20160918135030.GA7062@gondor.apana.org.au>
References: <20160804071846.GA773@gondor.apana.org.au>
 <20160804074546.GA996@gondor.apana.org.au>
 <1470377813.2977.14.camel@sipsolutions.net>
 <20160805104858.GA9297@gondor.apana.org.au>
 <1470394233.2977.37.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1470394233.2977.37.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 05, 2016 at 12:50:33PM +0200, Johannes Berg wrote:
> > My plan is to build support for this directly into rhashtable.
> > So I'm adding a struct rhlist_head that would be used in place
> > of rhash_head for these cases and it'll carry an extra pointer
> > for the list of identical entries.
> > 
> > I will then add an additional layer of insert/lookup interfaces
> > for rhlist_head.
> 
> Oh, ok.

OK, it's finally ready now.

This series contains one two patches.  The first adds the rhlist
interface and the second converts mac80211 to use it.  If this works
out I'll then proceed to convert the other insecure_elasticity
users over to this.

I've tested the rhlist code with test_rhashtable but I haven't
tested the mac80211 conversion.  So please give it a go and see
if it still works.

Thanks!
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
