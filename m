From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Wed, 2 Jun 2004 11:55:42 -0400
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040602155542.GC24822@ruslug.rutgers.edu>
References: <20040602071449.GJ10723@ruslug.rutgers.edu>
	<20040602132313.GB7341@jm.kir.nu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============85596900535849341=="
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Netdev <netdev@oss.sgi.com>, hostap@shmoo.com,
	prism54-devel@prism54.org, Jeff Garzik <jgarzik@pobox.com>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
In-Reply-To: <20040602132313.GB7341@jm.kir.nu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org


--===============85596900535849341==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yNb1oOkm5a9FJOVX"
Content-Disposition: inline


--yNb1oOkm5a9FJOVX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 02, 2004 at 06:23:14AM -0700, Jouni Malinen wrote:
> On Wed, Jun 02, 2004 at 03:14:49AM -0400, Luis R. Rodriguez wrote:
>=20
> > I'm glad wpa_supplicant exists :). Interacting with it *is* our missing
> > link to getting full WPA support (great job Jouni). In wpa_supplicant=
=20
> > cvs I see a base code for driver_prism54.c (empty routines, just provid=
ing skeleton).
> > Well I'll be diving in it now and see where I can get. If anyone else is
> > interested in helping with WPA support for prism54, working with
> > wpa_supplicant is the way to go.
>=20
> I have a bit more code for this in my work directory somewhere (setting
> the WPA IE and a new ioctl for this for the driver). I did not submit
> these yet since the extended MLME mode was not working and the changes
> were not yet really working properly. I can try to find these patches
> somewhere.. Anyway, I would first like to see the extended MLME mode
> working with any (even plaintext) AP and then somehow add the WPA IE to
> the AssocReq. After that, it should be only TKIP/CCMP key configuration
> and that's about it..

If you find the patches that'd be great :). I'll see what I can do about
fixing up extended MLME. I'll keep you posted.=20

> > I'm curious though -- wpa_supplicant is pretty much userspace. This was
> > done with good intentions from what I read but before we get dirty=20
> > with wpa_supplicant I'm wondering if we should just integrate a lot of=
=20
> > wpa_supplicant into kernel space (specifically wireless tools).
>=20
> Why? Which functionality would you like to move into kernel? Not that
> I'm against moving some parts, but I would certainly like to hear good
> reasons whenever moving something to kernel space if it can be done (or
> in this case, has already been done) in user space..

I have yet to review most of the wpa_supplicant code so I cannot say for
sure yet what I think should go into the kernel. I e-mailed most lists
mainly to get comments from others who have poked at wpa_supplicant
and/or are looking into adding WPA client support into their drivers.
I just wanted to make sure we were heading in the right direction since
I only see 2 drivers that are currently using wpa_supplicant.

> > Regardless, as Jouni points out, there is still a framework for WPA tha=
t needs
> > to be written for all linux wireless drivers, whether it's to assist
> > wpa_supplicant framework or to integrate wpa_supplicant into kernel spa=
ce.
>=20
> The first thing I would like to see is an addition to  Linux wireless
> extensions for WPA/WPA2 so that we can get rid of the private ioctls in
> the drivers. Even though these can often be similar, it would be nice to
> just write one driver interface code in wpa_supplicant and have it
> working with all Linu drivers.. I hope to find some time to write a
> proposal for this.

I agree :). Jean? *poke*

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--yNb1oOkm5a9FJOVX
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAvfh+at1JN+IKUl4RArobAJ90VhiqoBhMVDqVYNyrSVF7/oCWpwCcCgMw
BNTyXala+SrO9iduCpBy7CQ=
=FuH1
-----END PGP SIGNATURE-----

--yNb1oOkm5a9FJOVX--

--===============85596900535849341==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
HostAP mailing list
HostAP@shmoo.com
http://lists.shmoo.com/mailman/listinfo/hostap

--===============85596900535849341==--
