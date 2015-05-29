From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of most of the trees
Date: Fri, 29 May 2015 10:36:45 +1000
Message-ID: <20150529103645.57579e82@canb.auug.org.au>
References: <20150528220607.67a68696@canb.auug.org.au>
	<20150528.114203.717794268051352731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/OtEd_yb1YUMU9CnYj.2pHXu"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150528.114203.717794268051352731.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/OtEd_yb1YUMU9CnYj.2pHXu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 28 May 2015 11:42:03 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> The only thing I will say on this matter is that the _only_ way this
> problem will go away is if someone does the work necessary to get rid
> of that implicit vmalloc.h include that happens on all x86 platform
> builds.
>=20
> So if you want this to stop happening, work on that.

I may have a look in my (copious) free time :-)

> I've applied the following to net-next, thanks for your report.

Thanks for that.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/OtEd_yb1YUMU9CnYj.2pHXu
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVZ7SlAAoJEMDTa8Ir7ZwVBQ0P/2zfkVn6Ixnho1Wq2oDArBn8
EaYRVgjJ+wg040oR82u6Ew650HXHk2NgBFflRjN0kBY9b5piwbJcs5Doq4WhlfIG
+cscXjc1fZjBZmYNMUU75CYX288tWFvuX0VkwCdJNnQZ+a4wM3A/SJRXT/NYrNNr
e6u6ndyNNrh+lMMQUQtOQy7H6itsOln5jZLD1DAB+iiXbs7bjrE44wIfsnI8GLi5
CZTCeR7wZeCqPX93Iofy1b/k2psjRdhoaPPBq1rDySNbjpWbglfPMb5Mco4toNNF
1kICSbfSA3oLuCQlA6UEWgwV/4NdoHYtlyj357bf/HXLzhvLJQAI75ttdp6B7Ami
7RCxnV24h5lzPrINa0Sx8Oufa8ehz4v+SrRIFi4OuMVic9nbO+six/OH9ZHRWrnn
9j0o/yrCX4ahvIW7Dxas63HjfuOcBiKMP688s1NPK5enSJ0M2HNsAaeDnobPxTOX
2xLT1E5E4UACXfr33Q6E/szqmMT/tvNlISU7EBhwCrzy8anVzZXGu925Ggd0hcnz
xPtffa0r4eVomcq1SGbzpUxdlSUxyrQ8eOf7tlcRKq0JPncwTWI8/0ff3AwwzQ/Q
HM4WMbN8rm6qGZzjUdPLm773qhKTIpBgbUtWqGCJKfjrrKoxUWA/ibXKq28qXG0u
dKVGdouZqE6A3n4WRs5G
=Y3Hu
-----END PGP SIGNATURE-----

--Sig_/OtEd_yb1YUMU9CnYj.2pHXu--
