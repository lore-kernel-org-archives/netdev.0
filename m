From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH net-next,v3] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Thu, 20 Mar 2014 08:00:10 +1100
Message-ID: <20140320080010.77e27d5d7086a57d39f79e6d@canb.auug.org.au>
References: <1395180922-2776-1-git-send-email-haiyangz@microsoft.com>
 <20140319.164005.1815461875771862691.davem@davemloft.net>
 <532A1275.2020208@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5003989740609375182=="
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 David Miller <davem@davemloft.net>, haiyangz@microsoft.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <532A1275.2020208@cogentembedded.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

--===============5003989740609375182==
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__20_Mar_2014_08_00_10_+1100_QDRBkewNJOGf8hMP"

--Signature=_Thu__20_Mar_2014_08_00_10_+1100_QDRBkewNJOGf8hMP
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 20 Mar 2014 00:56:05 +0300 Sergei Shtylyov <sergei.shtylyov@cogente=
mbedded.com> wrote:
>
> On 03/19/2014 11:40 PM, David Miller wrote:
>=20
> >> +extern u8 netvsc_hash_key[];
>=20
> > We no longer use extern in header file function declarations.
>=20
>     Wait, this is a variable declaration. :-)

And the need for the extern on variable declarations was one reason I
gave for not removing it from the function declarations (consistency is
good :-)).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__20_Mar_2014_08_00_10_+1100_QDRBkewNJOGf8hMP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTKgVfAAoJEMDTa8Ir7ZwVbuQP/13NLiZY8wm0HgwWS9g5BGG4
hmATXGx9PAB4PATreeLeEORES0BDyrxTGXwv9hgFrPPtxyAJO4VmGQnnbztis4RS
GSeZId3e476jFW3VuzXnok4nWyWIGPtkKRUjS9mYYJ3PfgKcG9s9yMy0SpvWUlwf
WpV8vRWYbRTIv+HCw3buq2T9nFzATLTDh3qhuhqvZ2WQU+Sxs7y/fx4nKrurPEkn
aL8PwHElJEB4g3qdNsFzW2CXQ8O0M+tK3frDY11c7+JdBAUtf8u3S8yU3rZunSKM
WYbmlGPKo2GFKs43Sxf1Kiy54voqNwqp5qDBru6A9PxOFj3SOOxAgaPv542txvZ/
oJuhYaY4d5fY/RpG0ZMAUOaY4fa9FTM9HXHxVuslJ6Dt1rsVIrumUD7eb84m+jCm
GhCWdo9N/ohHZsQMZz/Bv+kxNTSkmNAwAsW0oJmtwe4jixK6VZZoib2M+2wPetDb
ndrR7OlsJ2qHxrnG6QF9o5BsJqMUwwmrkIiCm4zJTS4cGTv19yU/PL68xKA8ZAYt
o60+3uASE4DHMfd7kE/ca3N0MlGV4cP9Aw3CKoGDsn5SINyvWYeWqg5Dq0pDSNtU
cB8B5HPCMTmsvGpf0PFdJWLMNgByPU1xrnsEjaCaVBGnj64wr8UpEDfzzJxkNVV4
0xq0k1V39rV9qPU2xsM6
=khds
-----END PGP SIGNATURE-----

--Signature=_Thu__20_Mar_2014_08_00_10_+1100_QDRBkewNJOGf8hMP--

--===============5003989740609375182==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============5003989740609375182==--
