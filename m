From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 1/5] AF_RXRPC: Add blkcipher accessors for using kernel data directly
Date: Thu, 08 Mar 2007 17:55:46 -0500
Message-ID: <200703082255.l28MtkE8030073@turing-police.cc.vt.edu>
References: <20070308224806.17456.13944.stgit@warthog.cambridge.redhat.com>
            <20070308224829.17456.97200.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1173394546_10421P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030855AbXCHW4K@vger.kernel.org>
In-Reply-To: Your message of "Thu, 08 Mar 2007 22:48:29 GMT."
             <20070308224829.17456.97200.stgit@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1173394546_10421P
Content-Type: text/plain; charset=us-ascii

On Thu, 08 Mar 2007 22:48:29 GMT, David Howells said:
> 
> diff --git a/include/linux/crypto.h b/include/linux/crypto.h
> index 779aa78..ce092fe 100644
> --- a/include/linux/crypto.h
> +++ b/include/linux/crypto.h
> @@ -40,7 +40,10 @@
>  #define CRYPTO_ALG_LARVAL		0x00000010
>  #define CRYPTO_ALG_DEAD			0x00000020
>  #define CRYPTO_ALG_DYING		0x00000040
> -#define CRYPTO_ALG_ASYNC		0x00000080
> +
> +#define CRYPTO_ALG_CAP_MASK		0x00000180	/* capabilities mask */
> +#define CRYPTO_ALG_ASYNC		0x00000080	/* capable of async operation */
> +#define CRYPTO_ALG_DMA			0x00000100	/* capable of using of DMA */

Would it make sense to define ALG_CAP_MASK as 0xF80 or similar, to reserve
a few bits? The alternative has somebody else grabbing 0x200 for some other
purpose, and then when you want to add another capability bit, you end up
with a CAP_MASK of 0x580 - this way leads to madness and bugs....

--==_Exmh_1173394546_10421P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFF8JRycC3lWbTT17ARAjMPAJ9BIP7d6PhCrkqVDe/De9gUeO8fLACgj17e
yrFpNbkD+p7QqSTezk754Mw=
=ngWq
-----END PGP SIGNATURE-----

--==_Exmh_1173394546_10421P--
