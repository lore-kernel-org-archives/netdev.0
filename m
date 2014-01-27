From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 1/3] net: via-rhine: switch to generic DMA functions
Date: Mon, 27 Jan 2014 15:28:43 +0000
Message-ID: <1390836523.2735.155.camel@deadeye.wl.decadent.org.uk>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
	 <1390823503-24087-1-git-send-email-alchark@gmail.com>
	 <1390823503-24087-2-git-send-email-alchark@gmail.com>
	 <1390834190.2735.143.camel@deadeye.wl.decadent.org.uk>
	 <CABjd4Yyq_Mia=2DkC83Wpi6o1o3m5+yoMcDL4WdZmuLvRtu6qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ux9LAchQ19x2tdYiH7kd"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tony Prisk <linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roger Luethi <rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABjd4Yyq_Mia=2DkC83Wpi6o1o3m5+yoMcDL4WdZmuLvRtu6qg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-Ux9LAchQ19x2tdYiH7kd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-27 at 19:26 +0400, Alexey Charkov wrote:
> 2014/1/27 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>:
> > On Mon, 2014-01-27 at 15:51 +0400, Alexey Charkov wrote:
[...]
> >> @@ -1094,20 +1094,22 @@ static int alloc_ring(struct net_device* dev)
> >>       void *ring;
> >>       dma_addr_t ring_dma;
> >>
> >> -     ring =3D pci_alloc_consistent(rp->pdev,
> >> +     ring =3D dma_alloc_coherent(&rp->pdev->dev,
> >>                                   RX_RING_SIZE * sizeof(struct rx_desc=
) +
> >>                                   TX_RING_SIZE * sizeof(struct tx_desc=
),
> >> -                                 &ring_dma);
> >> +                                 &ring_dma,
> >> +                                     GFP_ATOMIC);
> > [...]
> >
> > Indentation is messed up here (and in several other function calls
> > you're changing).  You should align the function arguments so each line
> > begins in the column after the opening parenthesis.
>=20
> Ben, thanks for pointing out. I actually just tried to follow the
> style of surrounding code, but happy to adjust if that's the preferred
> option. From what I can see, these lines should still fit in below 80
> cols even with increased indents...
>=20
> Should we then also adjust other function calls within the driver with
> similar indentation (if any), that are currently not touched by this
> patch series?

There is no need to do that at the same time, but it would be a nice bit
of cleanup.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-Ux9LAchQ19x2tdYiH7kd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuZ7K+e/yOyVhhEJAQq8mxAAxx+rkZhozFIH9lRRo21YsW22gdWeMENt
gE8kEHnBqCNPwTzI0sIGsyMU4c3b10+Qn3+1wEHgwVr6qnw9lCco2ypzjjWVN/K6
JjtexHuLhpLy5dGgVWRYLwxm/3mqQoZYbprGzCFtxzU4TZ2DUAVdyzUajYQKEBjJ
viynRzlMmM3IbKPnjNmaxymOkSMpMSsFOPBUPNC8ne/fHtZE9Xt1JbRCu590r27/
R69kPtQCU6kTnUYGFv1797roDMGGDHZPjAATSpEI5ZrU9ejp9gdBld1/4iSrL/WR
rtoGGqZTNAwBPBK1CrLJG9YcgybY8W29FT9Ctxhv65U9RmSNYFOWo/k8tlBFfsFu
AuDPSMoc81pxLA0S2ahWSn0gn31h3+yrg/HnWsAgrbX/YPMu/y8zoQm1j2svmz+e
d8VkTonj8teOvVrKgZ7xb3pSyJwCposcl+KKhCiofOZF4LKIoxnHcGP37hLjzfgt
xqz9a6xZNcSo1tak0lm36Hc5SbsqEppuqkkHX7StmDCKfBKqTpvecyQr1LdXv+p4
sGDe9z6sP82hucYW4+/6i5XxX1Clv7tzCXnOKUMwNQ4y58m0dsl2XruN3E7oVDgK
ME8egLF/VW8FnFBFuOSzGzK8Ll54DxpbEJTEtf9mcSkq2y9rTiityCuw46rzlLCV
IDQk5XhuTRY=
=xyCp
-----END PGP SIGNATURE-----

--=-Ux9LAchQ19x2tdYiH7kd--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
