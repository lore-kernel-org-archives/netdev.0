From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [RFC PATCH 2/2] bpf: Initialise mod[] in bpf_trace_printk
Date: Wed, 9 Aug 2017 08:39:27 +0100
Message-ID: <20170809073926.GO6973@jhogan-linux.le.imgtec.org>
References: <59897A7C.10009@iogearbox.net>
 <20170808.094857.245786887664041622.davem@davemloft.net>
 <650EB3B0-1101-4624-905A-E68D2EC5920F@imgtec.com>
 <20170808.145433.1287676484744976417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="BaF3oFAMAE5aqUTc"
Cc: <daniel@iogearbox.net>, <ast@kernel.org>,
        <linux-kernel@vger.kernel.org>, <rostedt@goodmis.org>,
        <mingo@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170808.145433.1287676484744976417.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--BaF3oFAMAE5aqUTc
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 08, 2017 at 02:54:33PM -0700, David Miller wrote:
> From: James Hogan <james.hogan@imgtec.com>
> Date: Tue, 08 Aug 2017 22:20:05 +0100
>=20
> > cool, i hadn't realised unmentioned elements in an initialiser are
> > always zeroed, even when non-global/static, so had interpreted the
> > whole array as uninitialised. learn something new every day :-)
> > sorry for the noise.
>=20
> You didn't have to know in the first place, you could have simply
> compiled the code into assembler by running:
>=20
> 	make kernel/trace/bpf_trace.s
>=20
> and seen for yourself before putting all of this time and effort into
> this patch and discussion.
>=20
> If you don't know what the compiler does, simply look!

Well, thats the danger of wrongly thinking I already knew what it did in
this case. Anyway like I said, I'm sorry for the noise and wasting your
time (but please consider looking at the other patch which is certainly
a more real issue).

Thanks
James

--BaF3oFAMAE5aqUTc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlmKvCEACgkQbAtpk944
dnpF4w//djZS9WtaJgGrSoqO4QNxXNCq7kAv+hLNXCrvqmt8/OosScbZVDZvL8QQ
XTA/jLsaWJn4sYH4aoYMRGbZAmoouQlQgQ5OWUpKoml8ONrUujPARTbsdhS7TC5G
J+KlNK7hKbZ/wYy4xI7Ov5Kexq2aXWSRHQQkV3e7InAJbMU25A2zhFKO0MUwceMy
S5JFC2+02qYj/PqIjk/pK1dMaGbwFIE+cbeKc/uNxAajYmnwJKHYJtjYRfewrgUl
VSUR1qQtU2Km18XxGDXimDBpUmx1QN8iiBSyX879fM5I0F8oRaldw5OYZY+fSU7z
6LyEXdUVVnF7hgP5K2TguCg5Dj4KcOUMmNmbSTt3iEkZg4GsFqMfM5thASjm+5dr
hSet01eikqxsUmOQq73MO2JbEkoc11R9uxcVS9TOw3EbmJYB6I1MynDZT+xjjERK
LdkAIGg4cv9d9xwToFM+50oRRKS30fQjOsWpZR6jX6cxudfpf5wwxSG5cTPNIsOF
sw6Lxdu9Hght6+zUw4hzDs4UNmknh3EzfIVKr8cKBygarmUiMfgQn5L3DVRqxFCY
Q4a5cr3Vg1DC9SBSG6w/tsEE1MDJmx9Ff4Ri/0J8G1pLKhFkfVHSKyMKDPUNbEMF
NJmIj4VSK0rSnQWaAzIgFVRas33QZ+WjfbtEKNJih7l2PLTJhSk=
=la/Y
-----END PGP SIGNATURE-----

--BaF3oFAMAE5aqUTc--
