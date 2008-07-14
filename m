From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another Problem)
Date: Mon, 14 Jul 2008 21:52:19 +0200
Message-ID: <200807142152.26163.eike-kernel@sf-tec.de>
References: <4861800B.90703@nscus.com> <48777BC3.6090108@dell.com> <1216052460.23392.14.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1302757.VNAFtA2WZ5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Mario Limonciello <mario_limonciello@dell.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Kasper Sandberg <lkml@metanurb.dk>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1216052460.23392.14.camel@localhost>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1302757.VNAFtA2WZ5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Kasper Sandberg wrote:
> On Fri, 2008-07-11 at 10:26 -0500, Mario Limonciello wrote:
> > Kasper:
> >
> > http://marc.info/?l=3Dlinux-netdev&m=3D121498012600793&w=3D2
>
> I just tested it. It fails.
>
> after a few unloads/loads the lspci -x output is garbled again. the
> funny thing is (i have a dual nic board) its random which one that
> breaks..
>
> Francois, i tested your patch,
> http://userweb.kernel.org/~romieu/r8169/2.6.26-rc9/20080710-r8169-test.pa=
tc
>h against .26 and it WORKS. with all the other tests i've done, ~5
> unloads/loads is more than enough to trigger it, i just did 50 on your
> patch, and it functions.

Is there any chance this helps with the famous 8101 problems, e.g.=20
http://bugzilla.kernel.org/show_bug.cgi?id=3D6807 ?

> Now i can have both msi and apic on.. Thanks alot.
>
> Do you have plans to get this merged?

There is a typo in the description of 91ba1a976c214766b5ee8c6d17086903c10f6=
405=20
(serie should be series I think).

Greetings,

Eike

--nextPart1302757.VNAFtA2WZ5
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQBIe656XKSJPmm5/E4RAlIKAJ4/jquOMAlNKBrVR7ogvv/E5rEwwwCgoew7
IHIiDMB24CPGdrBGMiBWjn8=
=E/Yz
-----END PGP SIGNATURE-----

--nextPart1302757.VNAFtA2WZ5--
