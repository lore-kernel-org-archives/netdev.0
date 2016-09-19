From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [v2 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Mon, 19 Sep 2016 12:10:27 +0200
Message-ID: <1474279827.4469.30.camel@sipsolutions.net>
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
         (sfid-20160919_113440_719977_971CE718) <1474278634.4469.25.camel@sipsolutions.net>
         (sfid-20160919_115045_089605_A254E125) <1474278896.4469.26.camel@sipsolutions.net>
         (sfid-20160919_115508_261438_39410159) <1474279330.4469.28.camel@sipsolutions.net>
         (sfid-20160919_120228_517669_28A2A922) <1474279492.4469.29.camel@sipsolutions.net>
         (sfid-20160919_120500_879459_486B5001)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474279492.4469.29.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> (sfid-20160919_120500_879459_486B5001)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Btw, for debug I put

BUG_ON(atomic_read(&ht->nelems) < 0);

after the atomic_dec() in __rhashtable_remove_fast_one(). That makes
the kernel crash instantly on the buggy code, and I just have to run a
single test ("wpas_ctrl_interface_add_many") to get there.

johannes
