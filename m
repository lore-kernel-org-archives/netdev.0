From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 13:49:35 +0200
Message-ID: <1209642575.3904.2.camel@johannes.berg>
References: <20080501.024320.212547875.davem@davemloft.net>
	 <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	 <20080501.034950.261408566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3UUXvEO9lQPH2yVYLr5P"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080501.034950.261408566.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-3UUXvEO9lQPH2yVYLr5P
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

> =20
> +	if (unlikely((nhead || ntail) && skb->sk)) {
> +		printk(KERN_ERR "SKB BUG: Illegal pskb expand (%d:%d) "
> +		       "with socket attached\n",
> +		       nhead, ntail);
> +	}
> +

Also this could be a WARN_ON since here we really want to know who
called it.

johannes

--=-3UUXvEO9lQPH2yVYLr5P
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmuTqVg1VMiehFYAQLnOA/+L4n8YMleIsm84+EnIGXXXRi39PUTln+r
eQvsepwJTnnTX96FyZwUU62EazUssdHpkc1G19YKZ7CMhYdRKVd/3SraSx8gRgCm
BT3u+AoC7dedNOZtUOXbWDOChWjr0v5+mO0SLatS+4awznLt7URSmIpPFeFMF99a
mdb1ksUlG5o+fONfXnByztaR7CwI72+eGkpXjT6MOmQ2avNyzfQmh4caadh69usH
vJDPxERTUAKjTx3Zxs0zaYeuTKJ4oF0F9cti0RiV+PpzwCW3TnyQFCpLkFqWJ6W4
33Is/0YIURqdDOnvtOp2RVrFq+Ww9WdVss81G/hMOEmqS/fWR4gYY1uqvAFSlgVf
7OcsiQ7WR/7iIQENaNSippLFnsSeprmrLBF2pz0mX4p2Cznwg14aQCCeuBweiOwd
MUrujMq6tKx7GyZhEDDbWHH7fkxnTSBB7JZzjE3FDxl4FWimBcFDbIm12ZdwFdbW
Zbz0AzFIdLU3Z86byKyzGPFJUt2KnBS/rSaL04ec9+dq7EfGp4jDP5GbXEIQvwaD
s1UjDrkQ1FN6MZikKymV1FSH0nY6GCB7HdZ1mwserzbJt50VakflPM4NZ5j7++z/
gjA6gAZB2IkaFbn0CnR9CntmaSFoz9pDhA7Ow9EqtzPc3vEfqRkkquioFo8sSPwp
LF3WNNmxICQ=
=N+yL
-----END PGP SIGNATURE-----

--=-3UUXvEO9lQPH2yVYLr5P--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
