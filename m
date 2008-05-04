From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 4 May 2008 17:44:44 +0800
Message-ID: <20080504094444.GA541@gondor.apana.org.au>
References: <1209815533.3987.21.camel@johannes.berg> <20080503.180300.10562559.davem@davemloft.net> <1209865354.6210.23.camel@johannes.berg> <20080504020203.GA30514@gondor.apana.org.au> <1209866916.6210.39.camel@johannes.berg> <20080504021213.GA30660@gondor.apana.org.au> <1209867740.6210.46.camel@johannes.berg> <20080504031652.GA30993@gondor.apana.org.au> <1209890847.6210.51.camel@johannes.berg> <1209892489.6210.56.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1209892489.6210.56.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 04, 2008 at 11:14:49AM +0200, Johannes Berg wrote:
>
> I just re-did the test, and I definitely need 29 more bytes on, for
> example, the IPv6 autodiscovery packets and ICMP packets generated with
> ping(8). Some of them even need additional tailroom.

Could you find out the code path that created the skb in the
kernel so we can see why there isn't enough head room?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
