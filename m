From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic switch
 devices support
Date: Thu, 21 Aug 2014 09:41:23 -0700
Message-ID: <1408639283.13073.3.camel@deadeye.wl.decadent.org.uk>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
	 <1408637945-10390-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yeCm4XXD+lH5l3qfC3w3"
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48663 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750858AbaHUQlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 12:41:31 -0400
In-Reply-To: <1408637945-10390-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yeCm4XXD+lH5l3qfC3w3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-08-21 at 18:18 +0200, Jiri Pirko wrote:
> The goal of this is to provide a possibility to suport various switch
> chips. Drivers should implement relevant ndos to do so. Now there is a
> couple of ndos defines:
> - for getting physical switch id is in place.
> - for work with flows.
>=20
> Note that user can use random port netdevice to access the switch.
[...]

Why isn't the switch treated as a real device (not necessarily a net
device) that's included in the device model and that the port devices
refer to?

Ben.

--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.

--=-yeCm4XXD+lH5l3qfC3w3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU/YhM+e/yOyVhhEJAQoOZxAAzpZhEF5kpa7ljM50jq22dV2Osn32Xd3d
B8cX8xIL8TMxvt5lbvO2R40bpz3+AKO4Ae+yxyLj8pb8Oe9UCGDddRuy+MWc4KSv
w3CjFlzrazMPp+AUou1uSnstFkpnhWb1/BsTncCAjRADb8hBXDoHgWoyd5YUINSY
EDeELoCsqpUt78t9URoIl1VLcANs334tMryxBMWmKz7Au7HsmexU/7BMXSmXPAXp
RE6RjAlAh9gBTlULSoBRIu0DarEiBOd3x+U6fQD3rbV0quZXh9vlSPzUaAUKMDP/
Mx3VniKJxzIzFpPTCSqAlcaNI4wF2huspugUjVjv/qv+RP9Wqfh5GKiPL+9Y1crz
eBOC0C1zgBMVIEEEH6XEWQ+4bX4pP7tyTp2t3rCBpnTtQOI15VeKq1+Ee2w+S4VX
7H9lzt2KQxaroMHIfRNjvPbCj3WX6HzbPqJnPYdlBltTXbYRDlOmLfnX3mvRtRR+
2Du53qDyrMim5k9vDFAHUyF1TmpSMkMCqlmDfmFpgxdk6984V1fXqrrgvqt5EFXi
LHFpDPdZhCdB/2WvaJQC04HFbdFLDNlMzTJiQKIYPT8vWPqgQUwvX0jHcufTHtvs
kDqZKJVutN/FD2A3yzA7Orb3rLcpP1Fdc/kCTHOItPFFntYGtQbKyqAgTYwpF7dP
8mIfK/ggdwA=
=JTfZ
-----END PGP SIGNATURE-----

--=-yeCm4XXD+lH5l3qfC3w3--
