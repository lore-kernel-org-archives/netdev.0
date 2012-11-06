From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH v2 00/11] introduce random32_get_bytes() and random32_get_bytes_state()
Date: Tue, 06 Nov 2012 00:14:32 -0500
Message-ID: <90816.1352178872@turing-police.cc.vt.edu>
References: <1351957422-23243-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1352178872_2044P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	"Theodore Ts'o" <tytso@mit.edu>,
	Artem Bityutskiy <dedekind1@gmail.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	David Woodhouse <dwmw2@infradead.org>,
	linux-mtd@lists.infradead.org,
	Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	Robert Love <robert.w.love@intel.com>, devel@open-fcoe.org,
	Michel Lespinasse <walken@google.com>
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Sun, 04 Nov 2012 00:43:31 +0900."
             <1351957422-23243-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1352178872_2044P
Content-Type: text/plain; charset=us-ascii

On Sun, 04 Nov 2012 00:43:31 +0900, Akinobu Mita said:
> This patchset introduces new functions into random32 library for
> getting the requested number of pseudo-random bytes.
>
> Before introducing these new functions into random32 library,
> prandom32() and prandom32_seed() with "prandom32" prefix are
> renamed to random32_state() and srandom32_state() respectively.
>
> The purpose of this renaming is to prevent some kernel developers
> from assuming that prandom32() and random32() might imply that only
> prandom32() was the one using a pseudo-random number generator by
> prandom32's "p", and the result may be a very embarassing security
> exposure.

Out of curiosity, why the '32'?  I'm just waiting for some kernel developer to
do something stupid with this on a 64-bit arch because they think it's a 32-bit API. ;)

Should we bite the bullet and lose the 32, as long as we're churning the code *anyhow*?


--==_Exmh_1352178872_2044P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUJicuAdmEQWDXROgAQIpXQ/+OF2DqhEuVW7LL+uD224Wjp0lPNisDYJp
r52c5r7bu8P87/ds5XfYYqa5mnZ4kcoCtkMfGFRkOSQasv/vAzXAvtBva2uy8xKV
nmeO3S3cfTnCyFiOU3xUEkOsBQny3oUFTLCpcKdsoZl0zJKaPgFl2x5sR+t6z1eU
kVJehRoSJ+w3rHTdRFiLyH2sUdTJHGEClwnVsCmYoHhPuttWDOUFQry06B/1SjfU
Zpuc6dhVWeCRSB8RI4WCTfHwYEi7r6vk7Uhd39Nybn9D1BXrk46gMKeHTUf5cptR
jkk9pIaBK0XsRj1ZqrPoYJUTs//e7/l0LHY8XEGK2nn0Hvh4PEQmAf90mEVnxBFj
FHS9TE+MKXtRyTqcFMxDqH1fVinFJkf+QRgS2ibaOzEzIAukbFt8dSvfC+aBVkmg
VsdbRZSySppq9gUEpGq8xJiYkgctpUz4QcRFrfWMtX+eNpRnOevFr5jGUcxzF9+R
qQzA+a1/1e39jEH46P0YX0ZF7gOkpgvskKpArRHqtLmWrhM+gCkVbjy/2pfkD2Jl
Hh8aR9fz/YjUMY+Vlnbo7WY8ZU+LXepwErPDhPO10Yh3KmcYroFEPzNMb40EirSv
2KpQXYUZqO5YEFUpMDxdB2RDvddaoi8Qh0n26F7EX3b3KF+pdUv+9ihI4jyNLLTi
PRTdX/OpIPQ=
=wND5
-----END PGP SIGNATURE-----

--==_Exmh_1352178872_2044P--
