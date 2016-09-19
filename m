From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [v3 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 13:32:12 +0200
Message-ID: <1474284732.6544.2.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
         <20160804074546.GA996@gondor.apana.org.au>
         <1470377813.2977.14.camel@sipsolutions.net>
         <20160805104858.GA9297@gondor.apana.org.au>
         <1470394233.2977.37.camel@sipsolutions.net>
         <20160918135030.GA7062@gondor.apana.org.au>
         <20160919084056.GA11875@gondor.apana.org.au>
         <20160919105854.GA12892@gondor.apana.org.au>
         <1474283023.6544.0.camel@sipsolutions.net>
         (sfid-20160919_130358_323693_DD4A01BF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474283023.6544.0.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> (sfid-20160919_130358_323693_DD4A01BF)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-19 at 13:03 +0200, Johannes Berg wrote:
> On Mon, 2016-09-19 at 18:58 +0800, Herbert Xu wrote:
> > 
> > v3 fixes a bug in the remove path that causes the element count
> > to decrease when it shouldn't, leading to a gigantic hash table
> > when it underflows.
> > 
> Ok, with the BUG_ON() thrown in, this works in the test that was
> failing before. I'll run the entire suite again over lunch.
> 

Ok, the entire test suite passed (with the BUG_ON, but hey).

Dave, let me know what you want to do (or have done, as it may be).

Thanks,
johannes
