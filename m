From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Kernel v3.2 used in SlackWare 14.00 please, backport all needed
 patches Re: [PATCH net, 1/2] hyperv: Fix a kernel warning from
 netvsc_linkstatus_callback()
Date: Tue, 28 May 2013 04:10:46 +0100
Message-ID: <1369710646.3469.424.camel@deadeye.wl.decadent.org.uk>
References: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com>
	 <CACQ1gAi0JfJFAc822YT5xVfW8HkB8r_4rf0dXTNsi-1oChsPsQ@mail.gmail.com>
	 <00D0FAD3528A443BAEA3E39861B3CFAD@local.st.by>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uG1MESdLskG5lzxWCubH"
Cc: Richard Genoud <richard.genoud@gmail.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"Patrick J. Volkerding" <volkerdi@slackware.com>,
	KY Srinivasan <kys@microsoft.com>,
	Mike Sterling <Mike.Sterling@microsoft.com>,
	Olaf Hering <ohering@suse.de>, davem@davemloft.net,
	netdev@vger.kernel.org, olaf@aepfle.de, jasowang@redhat.com,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	stable@vger.kernel.org
To: Victor Miasnikov <vvm@tut.by>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <00D0FAD3528A443BAEA3E39861B3CFAD@local.st.by>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-uG1MESdLskG5lzxWCubH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-05-23 at 16:14 +0300, Victor Miasnikov wrote:
> Hi!
>=20
> > (the 3.2 version is different,
> > and it's instaging. (at not used by distros anyway))
>=20
>  No: used
>=20
> Linux Kernel v3.2 used in:
> -- SlackWare 14.00
>=20
> This is actual stable version SlackWare
>=20
> Please, backport all(!) needed patches
[...]
> P.P.P.P.P.S.
>=20
> Sorry, if my msg not full "political correct"
>=20
> I preffered solve problem as possibily earler, what wait big problems
>=20
> Sorry, again . . .

Please read Documentation/stable_kernel_rules.txt.  In short, you need
to identify the commit hash for each of the changes you want, and
provide the backported patch for any commits that can't simply be
cherry-picked.  I'm not going to read through all of what you wrote to
work out exactly what's needed.

I think Slackware might do better to backport the Hyper-V drivers from
Linux 3.4, as Debian and Ubuntu have done with 3.2-based kernels.  But
that sort of large backport isn't allowed on kernel.org stable branches.

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-uG1MESdLskG5lzxWCubH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUaQgNue/yOyVhhEJAQpZBA/8DBz4zYTLbuUsx0DJKvCufvUYZ2IamPLU
VlIVrRkVIlDwxOc8rFFoT7WtApPiD+dUMZE01vdk0qzCKiNfh/sE7HwqLNmvI8IM
BYqLVf7j5EaHnM/WiIZY9AmZYgopeiMftVYEpCfLhYoStTdfSE5vvOqAsdLW1l4T
83vExFbV2aGIAeQpoTHb3f8bH9Dx50I1e6nwQyS+KOBRu4gYaH40p9xzwBYZ4MJ4
HaczCOUMeO/iy7viLmDYtY7SMNHTXGYfL/iQBlf34SdR2g4ofF6Kx0CFZzrVDU6g
KWes9d/kVsPAHJ1MmF3OgnhlmQThSCmulQmG+TLnI4TlgUYiNR5cBudat8YEV22A
Cdjxuj12+E0U+yWLoZG/i/GI8U2a8gABi0WHAjGWk47Wy3Ax0qNsxmUeeXFkowOl
cLKlJvzhvT1f/jhN2YRt4xgna+4jV1rftxltBbT4VM11fTjTdKp4ywRomiJ7X9BP
Wijqx0X7hbrubUoc6lYUwW3oLlOUImbbGbUhh1etcmIyMPNQ/VXaBfYUdekC9Vhr
OLyrIRkT2maPQLn39n16RjL2QDIPYPYLMhH7EZFgobqQe76gL+3IAJIG60dGlhJ8
9iVt7Gtda5ioH4TvMGiowN8QU4lfjB8GoQSQoVvCg0eg4nwm2X9xgfAxgC8J8a97
p9CMZ0KflZE=
=FfJm
-----END PGP SIGNATURE-----

--=-uG1MESdLskG5lzxWCubH--
