From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast
 promiscuous control
Date: Mon, 09 Mar 2015 18:52:24 -0700
Message-ID: <1425952344.2579.20.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E53671@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4516310324716943022=="
Cc: "vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>, Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E53671@BPXM14GP.gisp.nec.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4516310324716943022==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-UuO7CdBoMXp8Ddybdbm8"


--=-UuO7CdBoMXp8Ddybdbm8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-10 at 01:42 +0000, Hiroshi Shimamoto wrote:
> > On 03/08/2015 02:15 PM, Or Gerlitz wrote:
> > > On Mon, Feb 23, 2015 at 11:14 PM, Jeff Kirsher
> > > <jeffrey.t.kirsher@intel.com> wrote:
> > > [...]
> > >> We discussed this during NetConf last week, and Don is correct
> that a
> > >> custom sysfs interface is not the way we want to handle this.  We
> agreed
> > >> upon a generic interface so that any NIC is able to turn on or
> off VF
> > >> multicast promiscuous mode.
> > >
> > > Jeff, please make sure to either respond to my comments on the V2
> > > thread (or better) address them for the V3 post.
> > >
> > >
> > > http://marc.info/?l=3Dlinux-netdev&m=3D142441852518152&w=3D2
> > > http://marc.info/?l=3Dlinux-netdev&m=3D142441867218183&w=3D2
> >=20
> > I agree with you that the patch descriptions should be cleaned up
> and
> > "beefed" up for that matter.
> >=20
> > If/when I look to push his series of patches, I will make sure that
> your
> > concerns are addressed so that we can get a accurate changelog.
>=20
> I see that the patchset should have better explanation in changelog.
> I will rewrite it and submit again.
>=20
> Jeff, are you planning to drop the patchset from your tree?
> I just concerned which tree I should create patches against for.

Yes, I will drop the current patchset in my queue.  I am in the process
of updating my queue, go ahead and make your patches against the
following tree:

git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
all-queue branch

If you give me an hour or so, I should have my tree updated with all the
patches in my queue currently.

--=-UuO7CdBoMXp8Ddybdbm8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU/k5YAAoJEOVv75VaS+3ObTMP/jZoWQkgBxjcgbw781T/0HH6
0rBO9lCfowygFTw80KpTxkFVbzBAjdRJDxZqxFr09uDt6FIh3Fg9XqOzXIr0nh8N
FJB5FjeMn0EOb1nJk0kKx4bt5ra0Vph1ao1sjYbjvXx7Ltnue460Sbye2Viuppan
3Vqp+p3RIJcgMd8bRDOkwXk0WIaT5GWUomugeXKEi89/1UI8CZAozzEfnmLDJBjV
N0pCpBmB2byJ/HHn7tXeAhoHagQG3sk5AGooIgoI/aYmYuvNgB5fyE8Xgnrj8xo0
YcreNch6A8CFf9KLjP0bAKnq1QM3RVY4c2eSb5N1QURTWxVyGUa1kYprjX97R0C7
yywvymTFfntlOTN6lAifx/2+w2zqwWtEYjd1lM++3jk3/cc7wtCBe5lNXfmjQWuh
UErXv3k2QwEMIODSNF4xyxQbnVaX3D660LJ2FQq9CjLDCKhFAYg5AmZ2WKNGGKRS
nz7EkbthbFF7he6pItjrNYwgiATgkPRcf8+pQY3mAc9gBOkHeD73Z3UdYasZG12c
pc8AWtUFC/8Eaf+OQYIIrRuWGgwAcR66N517Y9PP/ziXLnkQjEVcTwdDd9ObimWv
gixJKlLtn9pc0V8HM/k2e4qu3ICI9Bnq/FfYxceR+34Q7zVeit2YDldYh+ekM/3f
GW4U7sK89VypvqROmrU9
=KNOk
-----END PGP SIGNATURE-----

--=-UuO7CdBoMXp8Ddybdbm8--



--===============4516310324716943022==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
--===============4516310324716943022==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4516310324716943022==--
