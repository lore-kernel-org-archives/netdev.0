From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 14:52:41 +0200
Message-ID: <1209905561.4065.23.camel@johannes.berg>
References: <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 <1209892489.6210.56.camel@johannes.berg>
	 <20080504094444.GA541@gondor.apana.org.au>
	 <1209894754.6210.58.camel@johannes.berg>
	 <1209900355.6210.64.camel@johannes.berg>
	 <1209904088.4065.11.camel@johannes.berg>
	 <20080504124542.GA1455@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FCcq2GcFutyqc6Irka1Z"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504124542.GA1455-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-FCcq2GcFutyqc6Irka1Z
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> There are three ways out of this.  You could have your own cache
> (I haven't looked at your headers so I don't know whether that
> makes sense)

This doesn't really make all that much sense since 802.11 has not only
variable length headers but also needs a fixed BSSID in the header and
is pretty much intermingled with 802.3.

> have no cache at all,

That wouldn't be good either I think since we can actually use the
ethernet header quite well.

johannes

--=-FCcq2GcFutyqc6Irka1Z
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB2xmKVg1VMiehFYAQL0uxAAlpktHaMKVQwaJB65jqqhZs1wj0F85ds/
pQblzpKj+mt0nCAaRzUcPe2zv9rZQ1geWIEEk+CGC9ZAT5CGOtNZKwYr91Iq1tzp
PPZbNIx3XPoymWOP8Y3N7pZ2US6R1oRJSxmAZPnPGgKclUop0M5c/Fe8mSOKKDO6
oIyw3L42XR0cNqsKIEe8cPEP44VC0/56Jj2n8t8HSXIQ6px0vh0JWsfsAnzD3D9b
FyzZKdkLqaZrvTV41/vbajRXCi5F83APUJ3CKQCCjPiYboWHOgWVSergUF5CfiLV
UhJva64wWxpg1DH4udgFGos6ZlmG7TAROzM1uu88s84cGYw7WLlN3UH3kHPfYHt7
IcO8TD5GvG17T1YLnspcSaMhW11jxYhdedp39u0n32DU9xqAybw18c/T/tUabOj+
MzJPIlvKDrudi5x8UgGRpX6bRDdMEjmtGpHOBFtm0R8iixUr0AefUobtJcByNSa0
v+8nTDeG06XZrmwbmBa0At92ZrTZtiKbyeo3JXWWcyZgWXiLxmBXzl1U2kTj/X1Y
EIrBsdYIXK8VRHTieEx5L78JoiyT3NdSXJZZu6xDFOkqX2ZlVvGJGj709wvlmppo
7tFTzjNu2jszzSZbw7mhi8ceAS1Qw2QchdOpfa5KXF3NC91yhFbF8dOYEJSpReMs
OLPAC/dq7D4=
=uL1S
-----END PGP SIGNATURE-----

--=-FCcq2GcFutyqc6Irka1Z--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
