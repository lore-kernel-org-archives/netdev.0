From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH] CMAC support for CryptoAPI, fixed patch issues,
 indent, and testmgr build issues
Date: Wed, 23 Jan 2013 16:36:44 +0200
Message-ID: <20130123163644.19511ochn6jcqobo@www.81.fi>
References: <436404741.94502.1358773048618.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	linux-crypto@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <436404741.94502.1358773048618.JavaMail.root@elliptictech.com>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Tom St Denis <tstdenis@elliptictech.com>:

> Hey all,
>
> Here's an updated patch which addresses a couple of build issues and  
> coding style complaints.
>
> I still can't get it to run via testmgr I get
>
> [  162.407807] alg: No test for cmac(aes) (cmac(aes-generic))
>
> Despite the fact I have an entry for cmac(aes) (much like xcbc(aes)...).
>
> Here's the patch to bring 3.8-rc4 up with CMAC ...
>
> Signed-off-by: Tom St Denis <tstdenis@elliptictech.com>
>
<snip>
> diff --git a/include/uapi/linux/pfkeyv2.h b/include/uapi/linux/pfkeyv2.h
> index 0b80c80..d61898e 100644
> --- a/include/uapi/linux/pfkeyv2.h
> +++ b/include/uapi/linux/pfkeyv2.h
> @@ -296,6 +296,7 @@ struct sadb_x_kmaddress {
>  #define SADB_X_AALG_SHA2_512HMAC	7
>  #define SADB_X_AALG_RIPEMD160HMAC	8
>  #define SADB_X_AALG_AES_XCBC_MAC	9
> +#define SADB_X_AALG_AES_CMAC_MAC	10
>  #define SADB_X_AALG_NULL		251	/* kame */
>  #define SADB_AALG_MAX			251

Should these values be based on IANA assigned IPSEC AH transform identifiers?

https://www.iana.org/assignments/isakmp-registry/isakmp-registry.xml#isakmp-registry-6

-Jussi
