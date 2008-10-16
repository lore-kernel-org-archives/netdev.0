From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel oops when system under network stress
Date: Thu, 16 Oct 2008 13:41:59 +0800
Message-ID: <20081016054159.GA4696@gondor.apana.org.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alex@samad.com.au, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081015.215536.242281148.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 15, 2008 at 09:55:36PM -0700, David Miller wrote:
>
> [ Herbert, this looks like another case like that ebtables+tg3 one,
>   where the checksum field is not set properly. ]

Looking at the trace, I don't think ebtables plays any part since
it appears only on the receive path while the checksum problem is
on the transmit path.

I'm tempted to blame tg3's management of netdev feature setting
since it's far from obvious whether it enables TSOv6 only if IPv6
checksumming is also enabled.

Unfortunately I'm still stuck in some bog at the moment, but
hopefully I can resume looking at this issue in a couple of days.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
