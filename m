From: Valdis.Kletnieks@vt.edu
Subject: Re: next-20150610 - repeated hangs at e1000e_phc_gettime+0x2e/0x60
Date: Fri, 12 Jun 2015 17:34:25 -0400
Message-ID: <30284.1434144865@turing-police.cc.vt.edu>
References: <21937.1434077868@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1434144865_10236P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Thu, 11 Jun 2015 22:57:48 -0400."
             <21937.1434077868@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1434144865_10236P
Content-Type: text/plain; charset=us-ascii

On Thu, 11 Jun 2015 22:57:48 -0400, Valdis Kletnieks said:

> 0) next-20150603 works, so the problem landed in linux-next in the last week.
>
> 1) All 3 times happened while I was at home, using wireless, so
> the interface didn't have link and was ifconfig'ed down.

All 3 crashes happened at almost exactly 4 hours of uptime, but here
in my office I'm now at 6 hours on the same kernel while running with
the interface plugging in and doing traffic.

I have a fighting chance of mostly finishing a bisect over the weekend,
I'll let you know where that leads.

--==_Exmh_1434144865_10236P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVXtQYQdmEQWDXROgAQLZbhAAvMvncNYfVz6MULpe87yMKiRUD7Mn94Oi
IvuyWKmh6+noz/7DaUXE2kdOc51rviJhVmishTXUctGwFH9O/OT/EStwjF8QEtMD
UoXjZNFLFuPuuPDsnANGWJx8eCYBjgeWpK1CsYCG53AE1/tUyQJHK8b6QVKi6YKI
9nyxhxfZOJCAQUrtkzcXjNQ7g+AVNGPhSlIWxFODoaxSWbecZVYxq5zrQZ4CervP
8PAQ0QB8iw3VKKRJfQY2mPwJ7Q2N7geDaOLe2CVZmDShpOCN/TKYQ1Xsl7yy031t
aizzzXz2e08ngF3Xcf/pJ6TV0q+aR2by//xjxNHfYrjq5rJVsM6rIx+lpYTbhGNN
qJ9NRvkH+jn/1pNnFq7S5kEsMiGsCASW+rcydjl/inKEzkKOlx7JKF6bSO3O9zMV
SnEyg5HZRiY+4u8ojpZ25YrTYwvuLmZ4drQgvTVuOJiWrOlWOSRe+YEDHwl928GQ
PW81KPjos2g0yPwuHihSLnID9mVNfLrbnbiHgBVk6LZUOPoHMniSjSZ0hyxPtrZe
UZumkfgQWetqsRBpzPAtlFxeaZUFJmABIRTA5tW00s9uh02KmixcBlX572A0pMXT
NlsztDqwVh9LnyWmXIor1xIMuOEaphCEwIipE4lU/Hnvp1pE2x5bY3mXY1bh7QtZ
bcJTcfmFhT4=
=DGpF
-----END PGP SIGNATURE-----

--==_Exmh_1434144865_10236P--
