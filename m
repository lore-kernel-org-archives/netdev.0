From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Tree for Jan 25 (net/sock.h, jump_label, memcg)
Date: Fri, 27 Jan 2012 08:46:22 +1100
Message-ID: <20120127084622.a16b0f43e6fcbd029cb1f923@canb.auug.org.au>
References: <20120125141938.c1a9460d56948e1c7b26d3f8@canb.auug.org.au>
	<4F2052DB.4060602@xenotime.net>
	<CAMuHMdWp1wEHqPXNs+kaMYpomJnfbZPJjRk5GVFCuCL4Q5zK7g@mail.gmail.com>
	<20120126.134333.31948964659222759.davem@davemloft.net>
	<4F21B811.90904@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__27_Jan_2012_08_46_22_+1100_.y/YF/xi53=J/z4X"
Cc: David Miller <davem@davemloft.net>, <geert@linux-m68k.org>,
	<rdunlap@xenotime.net>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <gleb@redhat.com>,
	<netdev@vger.kernel.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4F21B811.90904@parallels.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__27_Jan_2012_08_46_22_+1100_.y/YF/xi53=J/z4X
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 27 Jan 2012 00:31:13 +0400 Glauber Costa <glommer@parallels.com> wr=
ote:
>
> On the specifics of this bug, I verified this config compiles okay in=20
> your tree + my patches at the day I last sent them. I also verified it=20
> breaks on the tree today.
>=20
> The reason seems to be that some other patch tweaked with the header=20
> files in an unrelated patch, and the static_branch definition that was=20
> getting to us in sock.h, is no longer getting there.
>=20
> Including it explicitly fixes it here. I will again pass through a=20
> battery of randconfigs on my own, and send you a fix.

Which is one of the reasons we have Rule 1 in Documentation/SubmitChecklist:

1: If you use a facility then #include the file that defines/declares
   that facility.  Don't depend on other header files pulling in ones
   that you use.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__27_Jan_2012_08_46_22_+1100_.y/YF/xi53=J/z4X
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPIcmuAAoJEECxmPOUX5FEG9IP/1gggtv6jmzcOLvedNBKjQp4
jnGk3IgNZ2AzNuDKcKO1pno0tpqbuC6Z//8Yk4Q8w4QCAK77ko+ejh0r/DhcEVjL
aGMLnG1qpUsgHHY6mOEYbSEVL+FwaVcq9asU1h9PNCZWle1awKDA7PJ6yh2VoUMS
amgWfNH9kp53nU6fYSOo74McEkSQsJkamVdj5AqiyhZ1O3v9A+mLLJ07dDIXHhOJ
w99/1tDsGlzaUHcCeXS3RzF4SKStEuIhhow5TV1BrRM2rTrk0hmJ8vpWU9QFIiWm
hYIPmSkJTuWm60JBiEHU6Phdlc2xKuU2nqjE+BTi9ifqXE5+J9YCkRyqBS4KhFs0
mS5+x4B7R1UTwb/gN/B8dQRSGmIbZ/oONOctJAdgqe3Abaq/HABuuaG8JK1g0whM
yj66RO5KdWFWGzxvWn+7SLa7tBTgjNLfGsLCHAlHQEPaH7sG9NfclfeM9C6v2ND+
KIK29M6tLTF7mbXIKb80XS/4Iy1zAhLt/jtDEy0eQ4+dEy9m4LCHQGO33IOtz8XB
miF+5z3QVYJWrVaowxJgMFbdBEC0eqYitUQsi4kvi4U3Nqpqc8ygXpbmhAnDWmJe
3uqkbS1EoFJU+kLzY8qM/eaAi9G8ryCUwQFBjm2xDF3Z3o2I5QDtdpz1y16e3LDs
n/aL3xE4aUcl0Fyrwvxa
=4l9l
-----END PGP SIGNATURE-----

--Signature=_Fri__27_Jan_2012_08_46_22_+1100_.y/YF/xi53=J/z4X--
