From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [RFC PATCH 02/12] net: infrastructure for hardware time stamping
Date: Tue, 16 Dec 2008 08:53:25 +1100
Message-ID: <E1LCLNV-0001EW-CN@gondolin.me.apana.org.au>
References: <1229352899-31330-3-git-send-email-patrick.ohly@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (Patrick Ohly)
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1229352899-31330-3-git-send-email-patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> @@ -305,6 +406,8 @@ struct sk_buff {
>                                ipvs_property:1,
>                                peeked:1,
>                                nf_trace:1;
> +       /* not all of the bits in optional are used */
> +       __u8                    optional;
>        __be16                  protocol;

You do reliase that this is going to grow the sk_buff by at least
4 bytes and not 1?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
