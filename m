From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 07/11] if_link: Add VF multicast promiscuous control
Date: Sat, 16 May 2015 04:56:15 -0700
Message-ID: <1431777375.32618.81.camel@jtkirshe-mobl>
References: <1430563358-113833-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1430563358-113833-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJ3xEMjtZOTkwXXk-EcSniYe99Rjz-BUTcyoZwKXpwh4DsPy+A@mail.gmail.com>
	 <F6FB0E698C9B3143BDF729DF22286646912ED354@ORSMSX110.amr.corp.intel.com>
	 <7F861DC0615E0C47A872E6F3C5FCDDBD05E9A253@BPXM14GP.gisp.nec.co.jp>
	 <F6FB0E698C9B3143BDF729DF22286646912EE34B@ORSMSX110.amr.corp.intel.com>
	 <7F861DC0615E0C47A872E6F3C5FCDDBD05E9DD71@BPXM14GP.gisp.nec.co.jp>
	 <F6FB0E698C9B3143BDF729DF22286646912EFEC4@ORSMSX110.amr.corp.intel.com>
	 <7F861DC0615E0C47A872E6F3C5FCDDBD05E9DDE9@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-j8arqwHLJpC5WO3oQTtB"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Edward Cree <ecree@solarflare.com>,
	Rony Efraim <ronye@mellanox.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8157 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbbEPL4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 May 2015 07:56:16 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E9DDE9@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-j8arqwHLJpC5WO3oQTtB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-05-12 at 00:33 +0000, Hiroshi Shimamoto wrote:
> > > -----Original Message-----
> > > From: Hiroshi Shimamoto [mailto:h-shimamoto@ct.jp.nec.com]
> > > Sent: Monday, May 11, 2015 4:55 PM
> > > To: Skidmore, Donald C; Or Gerlitz; Kirsher, Jeffrey T
> > > Cc: David Miller; Linux Netdev List; nhorman@redhat.com;
> > > sassmann@redhat.com; jogreene@redhat.com; Choi, Sy Jong; Edward
> Cree;
> > > Rony Efraim
> > > Subject: RE: [net-next 07/11] if_link: Add VF multicast
> promiscuous control
> > >
> > > > > > -----Original Message-----
> > > > > > From: Hiroshi Shimamoto [mailto:h-shimamoto@ct.jp.nec.com]
> > > > > > Sent: Wednesday, May 06, 2015 10:55 PM
> > > > > > To: Skidmore, Donald C; Or Gerlitz; Kirsher, Jeffrey T
> > > > > > Cc: David Miller; Linux Netdev List; nhorman@redhat.com;
> > > > > > sassmann@redhat.com; jogreene@redhat.com; Choi, Sy Jong;
> Edward
> > > > > > Cree; Rony Efraim
> > > > > > Subject: RE: [net-next 07/11] if_link: Add VF multicast
> > > > > > promiscuous control
> > > > > >
> > > > > > > > -----Original Message-----
> > > > > > > > From: Or Gerlitz [mailto:gerlitz.or@gmail.com]
> > > > > > > > Sent: Sunday, May 03, 2015 7:16 AM
> > > > > > > > To: Kirsher, Jeffrey T
> > > > > > > > Cc: David Miller; Hiroshi Shimamoto; Linux Netdev List;
> > > > > > > > nhorman@redhat.com; sassmann@redhat.com;
> > > jogreene@redhat.com;
> > > > > > Choi,
> > > > > > > > Sy Jong; Edward Cree; Skidmore, Donald C; Rony Efraim
> > > > > > > > Subject: Re: [net-next 07/11] if_link: Add VF multicast
> > > > > > > > promiscuous control
> > > > > > > >
> > > > > > > > On Sat, May 2, 2015 at 1:42 PM, Jeff Kirsher
> > > > > > > > <jeffrey.t.kirsher@intel.com>
> > > > > > > > wrote:
> > > > > > > > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > > > > > > >
> > > > > > > > > Add netlink directives and ndo entry to allow VF
> multicast
> > > > > > > > > promiscuous
> > > > > > > > mode.
> > > > > > > > >
> > > > > > > > > This controls the permission to enter VF multicast
> promiscuous
> > > mode.
> > > > > > > > > The administrator will dedicatedly allow multicast
> promiscuous per
> > > VF.
> > > > > > > > >
> > > > > > > > > When the VF is under multicast promiscuous mode, all
> > > > > > > > > multicast packets are sent to the VF.
> > > > > > > > >
> > > > > > > > > Don't allow VF multicast promiscuous if the VM isn't
> fully trusted.
> > > > > > > >
> > > > > > > > Guys,
> > > > > > > >
> > > > > > > > I don't think the discussion we held in the past [1] on
> the
> > > > > > > > matter actually converged. Few open points that came up
> while
> > > > > > > > debating it internally with
> > > > > > > > Rony:
> > > > > > > >
> > > > > > > > 1. maybe what we we actually want here an API that
> states a VF
> > > > > > > > to be privileged/trusted and then we can over load the
> feature
> > > > > > > > set of being
> > > > > > such?
> > > > > > >
> > > > > > > I suggested this originally, but there was push back as it
> was
> > > > > > > thought too
> > > > > > generic as the definition of what being a "trusted"
> > > > > > > vendor would differ from driver to driver.  Personally I
> still
> > > > > > > like the idea of
> > > > > > having one mode saying that we "trust"
> > > > > > > a given VF.  Then that VF can request whatever it support
> it
> > > > > > > wants from the PF regardless of possible negative impact
> on other
> > > VF's.
> > > > > > > What is possible to support would then be left to the
> interface
> > > > > > > between the VF and PF.  This of course would be dependent
> on
> > > > > > > what the
> > > > > > given HW could support and would mean this mode would mean
> > > > > > different things for different adapters and I do see why
> some
> > > > > > might see this as a concern.
> > > > > >
> > > > > > The point is granularity, right?
> > > > > > Allow everything or allow subset of features.
> > > > >
> > > > > Nice way to sum it up.  The trick being with the subset of
> features path is
> > > not all hardware can/will support everything.
> > > > > Also I worry about worry about the feature list growing
> requiring
> > > > > more and more nobs on the PF to allow/disallow granular
> behavior
> > > > > that could brake VF isolation.  With a simple hint to the PF
> that a given VF
> > > is "trusted" would allow all that complexity to be contained in
> the mailbox
> > > protocol between the PF/VF.
> > > > >
> > > > > All that said I realize others are concerned with the
> ambiguousness
> > > > > of such a field and can certainly live with your
> implementation.
> > > >
> > > > I see, it seems better to have a single knob which indicates
> "trust
> > > > this VF" and PF will allow requests which might hurt performance
> or
> > > > security from trusted VF, instead of creating a knob for
> multicast
> > > promiscuous, a knob for feature X and so on.
> > > >
> > > > I will make a patch to implement that "trusted knob" instead of
> allowing
> > > MC promiscuous.
> > > > Is there any comment?
> > >
> > > Any comments?
> > > Is that the way to go ahead this series?
> > >
> > > thanks,
> > > Hiroshi
> >=20
> > Clearly I am ok with the idea.  :)
> >=20
> > If the change isn't too difficult to implement, maybe just submit
> the path.  That will most likely get more attention.
>=20
> okay, I'll submit a new patches.
> BTW, which tree should I make patches against for?
> Because Jeff's tree still have previous patches.

So sorry for the delay, been dealing with some health issues.
I have removed your previous series of patches from my next-queue tree,
so you can re-spin your patches based on the dev-queue branch.

--=-j8arqwHLJpC5WO3oQTtB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVVzBfAAoJEOVv75VaS+3OZoUQAKewiwPDZ+bm/pfwGqBx3bUY
qVL+0j/Du5pnHlZW9/lZj1pruOcD3Maf+/IseMwFov7Sc05/H3xTVddgZqT6IN0d
yv/Ns+KvTnTMqcmudQZZPG4yXpoPTQXprUw/2kZi3PDrHzMq0zDftTWZXCaZLrtp
1AlnG/wIODkRCaqQgQDAgmhN6DfuH72JtwAlLogdscgjrIdj4pQ2Jl72pvaGlbCn
mFVAIoLA18TQ/cRY9WP1aE8gEYwBH9YKWko8+t2S1err35u4CNaOcnIrZBP58JHZ
AZuLv9gUxabEna7+aTI65iYqRnEb4KWn/CQN26JAtvLGp3HwbsW8jLlCdSB+o8Pw
ZtWDnUjdZZhoDnwgi457lNZw4K3+qnMN1ZMDeasZH5Ff4UaYZLOUO5BzEZHG20qE
ovamNHI4EbdMIhb92+pVPGk39ATiPoddQ5srScsM3dZpVWgT+gn7P+mPZ1sH/knL
zVIr2AMjxwiuVxzA/T19/PiPbFWZ3nu0amYw2p1iu98dSHNkB+7iAFnWVQqlxJJ/
yhSHSL/hjGnQd61lewNqpYS7A+WpzCkWyEtkzGcEzm9vPXuZrr/CGqV7jSRUVd+d
pma0MN2HgP6OPWJe8ByEbLZqkkvIOjwzhdnjJqY2saDjFTQ81irGbQFUIlcgQRdV
y5LK80lf5V8N3WtBjHpD
=cgkn
-----END PGP SIGNATURE-----

--=-j8arqwHLJpC5WO3oQTtB--
