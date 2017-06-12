From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: WARNING in dev_watchdog
Date: Mon, 12 Jun 2017 14:17:29 +0100
Message-ID: <1497273449.3477.69.camel@decadent.org.uk>
References: <CAJsXRPGWqm-DN2+VsEjCAOZV-C2GqkzmjPjJgRoGTUABJSFnow@mail.gmail.com>
         <20170612064232.GA14559@kroah.com>
         <CAJsXRPHmYk5FQBhwfP7d_Ah7cNHk=P_7-RLHzBTuLwrukqpBWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-qlS0oQBSUZMqd4xrBywa"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        security@kernel.org
To: Dison River <pwn2river@gmail.com>,
        Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJsXRPHmYk5FQBhwfP7d_Ah7cNHk=P_7-RLHzBTuLwrukqpBWQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-qlS0oQBSUZMqd4xrBywa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-06-12 at 16:13 +0800, Dison River wrote:
> Sorry,this WARNING is not reproducible.And I don't have PoC for this
> bug.

I found and reported a similar bug in e1000 and e1000e some years ago,
which was fixed in the latter here:
https://git.kernel.org/linus/d821a4c4d11ad160925dab2bb009b8444beff484

I think e1000 may still be unfixed, so this might be the same bug.

Ben.

--=20
Ben Hutchings
Unix is many things to many people,
but it's never been everything to anybody.

--=-qlS0oQBSUZMqd4xrBywa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlk+lGkACgkQ57/I7JWG
EQkq1A/+Mu1uUdhdDxzPRh2BiBxyAUOQ3aLPQ8px8XbYBE+BDJSeuCW1e94+4yWp
U3BIc/uaJJS6hIFPAstMiA2ZSXLjOlBgRbVLo0ZQVVCWWdW7jzGDsa0M481RW9cW
hgvJeKaTxtwmQhhhDggbytVcWQQ+6/5ptZtjCPju/EdDr0CbCRM2OHgXOvnY+sNH
DPrBVb390nHhu8NvyLbTg3OC3rs2T7VxpieITYDuYWeBlI+1JIHGNPldarwf2Bcf
v7Bz1ro5LnhmtGpltCk5jj0aBY3osve7dIoBX62KrzzpeFOnns8+eWkwc2VZnWKA
s4YqGxvJIDOzWkDVtO/uhUm9Uy3I8CqEJanODu0IFeUaS+xCGaMNYS12H7q4G4Qh
aXur7ecEM098nZtPG2rlnKpqLq8drMMy5HahjGyJW+x58RqQrEnWqvk4po06sd93
fVAYhduGtmkkVenSuxtVNUpeiraiOnmSeGfnSvWNYVKyEaT6JAKTtnzoBhtrVnYX
+dXVqyubY8sJePWWDLnFcnowKHrsQnTE7rnQcxvhS5fEsQNgIkRgnJ12NSUSadny
eIWCB9LibsrIU9ye4RBY69jafmmeaXT9qtPdoFkel7634nQeSFb1T4iiS5IAXZqp
uT3ehNhVU4tcnTUsUx5VmPF7pE54fK/+8E5MftIC4x/MXxTwtwc=
=uXpA
-----END PGP SIGNATURE-----

--=-qlS0oQBSUZMqd4xrBywa--
