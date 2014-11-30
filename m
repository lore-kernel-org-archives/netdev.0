From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] e1000: remove unused variables
Date: Sun, 30 Nov 2014 01:45:13 +0000
Message-ID: <1417311913.7215.111.camel@decadent.org.uk>
References: <1417065728-5592-1-git-send-email-sudipm.mukherjee@gmail.com>
	<alpine.NEB.2.11.1411262157110.1481@chris.i8u.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4975381317991321847=="
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Hisashi T Fujinaka <htodd@twofifty.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.NEB.2.11.1411262157110.1481@chris.i8u.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4975381317991321847==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1PgVn7v+jBrWGgzV56qP"


--=-1PgVn7v+jBrWGgzV56qP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-11-26 at 21:59 -0800, Hisashi T Fujinaka wrote:
> I'm pretty sure those double reads are there for a reason, so most of
> this I'm going to have to check on Monday. We have a long holiday
> weekend here in the US.
[...]

If there were double register reads being replaced with single register
reads, I'd agree this was likely to introduce a regression.  But all I
see is var =3D er32(REG) being changed to er32(REG).

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-1PgVn7v+jBrWGgzV56qP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHp2sOe/yOyVhhEJAQoGHw//SpO5726CRwxjBRtXTTFYjmOBzm2hki5j
pnkeWfii7bo+kWP4LpeZ3OHmDUW1MiopoUqUGwZDevpWjlN+1M4OC0TKfQnYVi1Y
sD/BFACNiNnynTDW9JiZLabHa0VPcMAHC0SjRenCcTNdlk+EryLTVynPui5/Ue+o
Fi7xaNouGrUozxK+ScKMOtwC1deyoTRRYULmDK+m6f10oJKzVm7JgaxpBkBq4qHg
irIIkHV2hvo52JOiEGJQOwCo241WyDR/7N72HqWR6JNWk/gdPHnQ41SJqZ22ZMar
mhG+O1Kb/hCtkr99s91dQn6f0NbO4z1lzUVuxof3xRyppbyhstkO/lsM+KzLufEk
qiuDcIaD0c0nW8m2GcZmVgqZYeDLT/FOfpbdVwaVwYrBrERtYwolMGS5lkeXYBDY
dFrMwoqulFoMxwDfSg28b2NsqaAVc+jtYMec+G+kgQkKz22zno5sn4fsRWOkwio/
4EkZ5E2zoqAfdEOmIa+jda9uzNbtfbhDhpPcfmBTbIomCGblsLuBowfXvAjw4Z60
ihuQiXBedQ0zpga9xw5ABT9dRQ98rL8pHcj0ORFLhiKWI3t26iiGr90LvEdSdWOZ
ZyIclPRRbDjISe66CaAX5ugKetWqh6NBbM4P3AUS99rSIFb9/7Dfn0yHiDrjj9Ne
R4r2BBJgc1c=
=AvQD
-----END PGP SIGNATURE-----

--=-1PgVn7v+jBrWGgzV56qP--


--===============4975381317991321847==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
--===============4975381317991321847==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4975381317991321847==--
