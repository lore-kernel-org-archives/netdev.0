From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in	RCU.
Date: Sun, 20 Jul 2008 22:20:42 +0800
Message-ID: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au>
References: <1216301732.4726.26.camel@localhost>
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216301732.4726.26.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> wrote:
>
> Actions are fine because they are intended to be globaly shared.
> [i.e A classifier on ethx with qdiscA:Y (in/egress) can share an action
> with  classifer on  ethy with qdiscB:Z (eg/ingress)].

Not all actions :) That nat action for example wasn't intended to
be shared at all.  In fact I still need to submit a patch to make
it skip the shared hash as otherwise it simply won't scale as the
number of nat actions increases (e.g., to 256K).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
