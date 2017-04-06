From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 3/4] xfrm: Prepare for CRYPTO_MAX_ALG_NAME expansion
Date: Thu, 6 Apr 2017 23:15:51 +0200
Message-ID: <20170406211551.GE12763@secunet.com>
References: <20170406081509.GB30557@gondor.apana.org.au>
 <E1cw2aQ-00085u-SY@gondobar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexander Sverdlin <alexander.sverdlin@nokia.com>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1cw2aQ-00085u-SY@gondobar>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 06, 2017 at 04:16:10PM +0800, Herbert Xu wrote:
> This patch fixes the xfrm_user code to use the actual array size
> rather than the hard-coded CRYPTO_MAX_ALG_NAME length.  This is
> because the array size is fixed at 64 bytes while we want to increase
> the in-kernel CRYPTO_MAX_ALG_NAME value.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
