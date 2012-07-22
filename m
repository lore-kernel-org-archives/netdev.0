From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 00/13] drivers: hv: kvp
Date: Sun, 22 Jul 2012 03:50:58 +0100
Message-ID: <1342925458.11373.210.camel@deadeye.wl.decadent.org.uk>
References: <20120621224737.GA5933@kroah.com>
	 <426367E2313C2449837CD2DE46E7EAF9155EC47A@SN2PRD0310MB382.namprd03.prod.outlook.com>
	 <20120622132547.GA2639@kroah.com>
	 <426367E2313C2449837CD2DE46E7EAF9155ED14D@SN2PRD0310MB382.namprd03.prod.outlook.com>
	 <20120626213954.GA4840@kroah.com>
	 <426367E2313C2449837CD2DE46E7EAF9155ED64A@SN2PRD0310MB382.namprd03.prod.outlook.com>
	 <20120626222205.GA5948@kroah.com>
	 <426367E2313C2449837CD2DE46E7EAF9155ED68D@SN2PRD0310MB382.namprd03.prod.outlook.com>
	 <20120628142340.GA21537@aepfle.de>
	 <426367E2313C2449837CD2DE46E7EAF9155EF399@SN2PRD0310MB382.namprd03.prod.outlook.com>
	 <20120702195721.GE1894@decadent.org.uk>
	 <426367E2313C2449837CD2DE46E7EAF9155EF7C6@SN2PRD0310MB382.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HSWNoAn65+LsjDKWl4J7"
Cc: Olaf Hering <olaf@aepfle.de>, Greg KH <gregkh@linuxfoundation.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <426367E2313C2449837CD2DE46E7EAF9155EF7C6@SN2PRD0310MB382.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HSWNoAn65+LsjDKWl4J7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-03 at 15:24 +0000, KY Srinivasan wrote:
>=20
> > -----Original Message-----
> > From: Ben Hutchings [mailto:ben@decadent.org.uk]
> > Sent: Monday, July 02, 2012 3:57 PM
> > To: KY Srinivasan
> > Cc: Olaf Hering; Greg KH; apw@canonical.com; devel@linuxdriverproject.o=
rg;
> > virtualization@lists.osdl.org; linux-kernel@vger.kernel.org;
> > netdev@vger.kernel.org
> > Subject: Re: [PATCH 00/13] drivers: hv: kvp
> >=20
> > On Mon, Jul 02, 2012 at 03:22:25PM +0000, KY Srinivasan wrote:
> > >
> > >
> > > > -----Original Message-----
> > > > From: Olaf Hering [mailto:olaf@aepfle.de]
> > > > Sent: Thursday, June 28, 2012 10:24 AM
> > > > To: KY Srinivasan
> > > > Cc: Greg KH; apw@canonical.com; devel@linuxdriverproject.org;
> > > > virtualization@lists.osdl.org; linux-kernel@vger.kernel.org
> > > > Subject: Re: [PATCH 00/13] drivers: hv: kvp
> > > >
> > > > On Tue, Jun 26, KY Srinivasan wrote:
> > > >
> > > > > > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > > > > > The fact that it was Red Hat specific was the main part, this s=
hould be
> > > > > > done in a standard way, with standard tools, right?
> > > > >
> > > > > The reason I asked this question was to make sure I address these
> > > > > issues in addition to whatever I am debugging now. I use the stan=
dard
> > > > > tools and calls to retrieve all the IP configuration. As I look a=
t
> > > > > each distribution the files they keep persistent IP configuration
> > > > > Information is different and that is the reason I chose to start =
with
> > > > > RedHat. If there is a standard way to store the configuration, I =
will
> > > > > do that.
> > > >
> > > >
> > > > KY,
> > > >
> > > > instead of using system() in kvp_get_ipconfig_info and kvp_set_ip_i=
nfo,
> > > > wouldnt it be easier to call an external helper script which does a=
ll
> > > > the distribution specific work? Just define some API to pass values=
 to
> > > > the script, and something to read values collected by the script ba=
ck
> > > > into the daemon.
> > >
> > > On the "Get" side I mostly use standard commands/APIs to get all the
> > information:
> > >
> > > 1) IP address information and subnet mask: getifaddrs()
> > > 2) DNS information:  Parsing /etc/resolv.conf
> > > 3) /sbin/ip command for all the routing information
> >=20
> > If you're interested in the *current* configuration then (1) and (3)
> > are OK but you should really use the rtnetlink API.
> >=20
> > However, I suspect that Hyper-V assumes that current and persistent
> > configuration are the same thing, which is obviously not true in
> > general on Linux.  But if NetworkManager is running then you can
> > assume they are.
>=20
> I am only interested in the currently active information. Why do you
> recommend the use of rtnetlink API over the "ip" command. If I am not
> mistaken, the ip command uses netlink to get the information.=20
[...]

'Screen-scraping' the output of administrative tools is not good
practice.  It may be the best you can do when writing a shell script,
but for a C program it's generaly less reliable and often more difficult
than using the underlying C API.

Ben.

--=20
Ben Hutchings
73.46% of all statistics are made up.

--=-HSWNoAn65+LsjDKWl4J7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUAtqkue/yOyVhhEJAQrhbRAAlwuiKyx4IkTbeZtGobWpsiO0k9uTblaC
/u6PRlcTf/H/e78pd8PcvrE0789Uwmxmj2KsMXkLtr6/+mIK91lhCMik6CeOcwUn
p4Zj1LnjaiHo9T12spUjW/ua6/CGDD9DPfHfTbl0HTsC2JVwwkxSQckC127GOvOf
Oi9KEUOyl6S/BkvZMp5MK2o7Gu45wP7kOCzwTnG6FlJQuxHxbxNLifmxaVB5XzF6
0I1pdlOOQH0Tg7GzSPjnX05MRUqOfmksXg3/xCiGBs7Mn/BuOTVpWjYBhtw3IaLr
10HNFBfywtGNVed4XKJjdP1OwID7FRAHphl8d8GptkVzzjwb1K+//UpQFot+w+6o
VeaFg/ttAuz3Pv5BpSZbkh0GLmf6Ew403eZkg2J4RasNF+dKRvKV47ibMYui62t/
R+vruFdqyMoMJfyY7mYlzjZz9i13ofTSRm3oOY1QDbbdZf8FCcAPLygOF9phvTEn
dzqRQZIvqdOvsRZtEo2n1y1kYtp8sCeS0iGFQQyGBo7xsHMbtVnsF71NK/3t9wD+
vi7UI6lIqFZXWzqDDDj6qmOW1QhN2r8FzV1I0qOhvBPMonW3xwh6dVbYJsLBppQT
5ZlCkQBehdvqD8KD+Z0Bq4TMK2ytVRyCUFB0lG5mwH2vZvFZuhOmA434ddBhu2uS
oFF+Qg31fCg=
=ujxn
-----END PGP SIGNATURE-----

--=-HSWNoAn65+LsjDKWl4J7--
