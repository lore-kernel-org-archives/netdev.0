From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 07/20] igb: add a character device to support AVB
Date: Wed, 24 Feb 2016 13:50:53 -0800
Message-ID: <1456350653.2808.28.camel@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1456287984-10459-8-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJ3xEMiHz+5n1iHO9s2Vuz_ssgJWTNBU-1gCgf_Bf0Rrc-kA-A@mail.gmail.com>
	 <20160224.164520.2124246431953318783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-diVZ9HK6PhOqUbQeGStN"
Cc: gangfeng.huang@ni.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: David Miller <davem@davemloft.net>, gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63496 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758022AbcBXVux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 16:50:53 -0500
In-Reply-To: <20160224.164520.2124246431953318783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-diVZ9HK6PhOqUbQeGStN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-24 at 16:45 -0500, David Miller wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>
> Date: Wed, 24 Feb 2016 22:06:25 +0200
>=20
> > On Wed, Feb 24, 2016 at 6:26 AM, Jeff Kirsher
> > <jeffrey.t.kirsher@intel.com> wrote:
> >> From: Gangfeng Huang <gangfeng.huang@ni.com>
> >=C2=A0
> >> This patch create a character device for Intel I210 Ethernet
> controller,
> >=C2=A0
> > wait, do we want L2 network driver to create char devices
> >=C2=A0
> >> it can be used for developing Audio/Video Bridging
> applications,Industrial
> >> Ethernet applications which require precise timing control over
> frame
> >> transmission, or test harnesses for measuring system latencies and
> sampling
> >> events.
> >=C2=A0
> > for various reasons such as the above?
>=20
> This is definitely not the direction to go for such a facility.
> Character devices make no sense at all, and are an invitation for
> ad-hoc user interfaces for what should be a generic and clean
> facility.
>=20
> There is no reason we cannot provide this facility with extensions
> of traditional networking APIs such as netlink or recvmsg/sendmsg
> over a raw or AF_PACKET socket.
>=20
> If there has been a lot of work, time and effort put into this
> character device solution then that's too bad.=C2=A0 Because anything tha=
t
> ends up being user facing should have been proposed here on netdev
> from the start.
>=20
> I'm not applying this, no way.

Thanks Dave, I will drop this and the associated patches from the
series.
--=-diVZ9HK6PhOqUbQeGStN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWziW9AAoJEOVv75VaS+3OUCQP/jkrdEpTwfJSj6H3yEfEXucd
gTsIgy4dcxGFM5wGoEHcPV/Cv6Cp+H1TYaQXEAurFwL5vDIx2ii3Wj/Eho3P4bE5
xyA2dPheR87FjP/Xv4p1hNX18fz5RJ1G/eFDG5FxgN4SpK6v63FyJriOjw2ah9xA
AgylDaYcERUo1JICXZqVl3BS3sWMUgcAbJuGIue31WI43xVrfkrQaq+gz5X0L9K6
bNeor3LxuhYnTYSwTLWq+llx4WvswzDTlIwbKX1fwJ+WFS0NABzWaY+gcOCDy0jT
BHm6Nm19PBUpCvSEZA3ANvtTOQzkBlqqYIFZZjj1MpUckjFfev3cgoVBEQptXDGB
BFxfc7hBUmHHiKpycKcKgl5s0bKgMKSL9h1GUUBsxjORlbnBtQYmEPheVvRoUFQa
IjVQ4J5NkDcLowg8epjNSJJP4DNIx65kPrclaMQ1397I9CCTITvQddFIAHhak2RB
ifZya7UdcncTRVxzBvnzPQ6OjDz7lbDDajS5AQuVNvrSl/6Rboujfkc2g+pQjFfQ
ZlR5CTI7Xg44W/XRQ9K26cnkwxS7Ir9RSWWg4vNXRHXvrFydp2ffXDEAzYe3FrlG
ganP1cXJ981DwFiDe2t9iCOLYW3LpqtCCmcb9C3pTF8JranWdCpim28HXt+nOnA2
BEB8h6Ic/+Uti1qqY7sV
=c+28
-----END PGP SIGNATURE-----

--=-diVZ9HK6PhOqUbQeGStN--
