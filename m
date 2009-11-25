From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] xfrm: Custom truncation lengths for authentication
 algorithms
Date: Wed, 25 Nov 2009 15:48:54 -0800 (PST)
Message-ID: <20091125.154854.99590537.davem@davemloft.net>
References: <cover.1259142145.git.martin@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: martin@strongswan.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1259142145.git.martin@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Willi <martin@strongswan.org>
Date: Wed, 25 Nov 2009 11:29:50 +0100

> The following patchset adds support for defining truncation lengths
> for authentication algorithms in userspace. The main purpose for this
> is to support SHA256 in IPsec using the standardized 128 bit
> instead of the currently used 96 bit truncation.
> 
> Martin Willi (3):
>   xfrm: Define new XFRM netlink auth attribute with specified
>     truncation bits
>   xfrm: Store aalg in xfrm_state with a user specified truncation
>     length
>   xfrm: Use the user specified truncation length in ESP and AH

All applied to net-next-2.6, thanks!
