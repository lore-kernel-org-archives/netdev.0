From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Move hardware headers for decaped packets
Date: Sun, 7 Dec 2003 20:55:27 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031207095527.GA2767@gondor.apana.org.au>
References: <20030925121131.GA17968@gondor.apana.org.au> <200309251228.QAA11650@yakov.inr.ac.ru> <20030925124102.GA18188@gondor.apana.org.au> <20031207090205.GA2358@gondor.apana.org.au> <20031207014714.03e79cd2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031207014714.03e79cd2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 07, 2003 at 01:47:14AM -0800, David S. Miller wrote:
>
> Ok, I'll review this again.  Did you audit the tree to make sure you
> updated mac_len everywhere that 'skb->mac.*' is modified?

To be honest, no.  The reason is that my use of mac_len starts from
netif_receive_skb and ends just before the reentrance into netif_rx
in xfrm[46]_input.

At the start of that path, mac_len is initialised from a value that
we know to be correct.  I have also verified that within the path,
nobody expands/contracts the MAC header.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
