From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] netfilter: Fix br_nf_pre_routing() in conjunction with
 bridge-nf-call-ip(6)tables=0
Date: Thu, 05 Jan 2012 20:54:55 +0100
Message-ID: <4F06000F.10303@nod.at>
References: <4F025A07.2000304@nod.at> <1325597164-13459-1-git-send-email-richard@nod.at> <1325597164-13459-2-git-send-email-richard@nod.at> <20120103081521.2fec3a29@nehalam.linuxnetplumber.net> <4F033E11.5060707@nod.at> <4F0361D7.3000602@pandora.be> <4F03650D.8050200@nod.at> <4F049290.3090803@pandora.be> <4F04DD19.601@nod.at> <4F05FF15.5010809@pandora.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBCBBD152521AE419BAC6D58E"
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F05FF15.5010809@pandora.be>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBCBBD152521AE419BAC6D58E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 05.01.2012 20:50, schrieb Bart De Schuymer:
> Op 5/01/2012 0:13, Richard Weinberger schreef:
>>
>> Let's export brnf_call_iptables and brnf_call_ip6tables, such that
>> physdev_mt_check() can notify the user that his iptables rule will hav=
e
>> no effect.
>>
>=20
> I don't want to introduce a runtime dependency between the iptables
> physdev module and the bridge module.
> This should keep working:
> #modprobe bridge
> #modprobe xt_physdev
> #rmmod bridge
> It will stop working if you use exported symbols of the bridge module i=
n
> the physdev module.
>=20

IMHO this behavior would be useful. 8-)

Removing bridge while xt_physdev is loaded will make some netfilter
rules void.
Which is not fun on a production firewall.

Thanks,
//richard


--------------enigBCBBD152521AE419BAC6D58E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPBgAQAAoJEN9758yqZn9eknAIAL1xVa5ClYRqdGMmXeJ1cdk5
u1aqx89IJLtGCnuQ7RZChpXjoRUCKejokGbMoQzN6NN2iZayzAqYPA8YJXptE1lw
5d3/QklB9zVr7KxwXVdBHg7FagbLJMfPT66JX2Y6CkyP/w0Qw1UdRiGtJW3fLMbG
Vcn3NWh4fWpPe4Wb4BsA9CLjXHL7o6QBUE1Y4oka1hbzP5Xu4roMg++TwhZ/w3Zp
JQ8dz4mPAO9InpXNv1ulaX3ImkP/XXO/nEhF3lKSkZvnND8ZoxazIrJDqloaWQ5W
rAhW5v3XMy8YdG9gtCwfCnFv29Ocjp7j0OLnh2RsQVITDn4fpI1G0D3HETsIc/I=
=fFns
-----END PGP SIGNATURE-----

--------------enigBCBBD152521AE419BAC6D58E--
