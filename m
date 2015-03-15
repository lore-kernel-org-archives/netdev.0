From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 fails to work with certain device names
Date: Sun, 15 Mar 2015 09:24:11 +0200
Message-ID: <20150315072411.GA11071@angus-think.lan>
References: <op.xvifrvrh5ica7l@skepsis.pre.is>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Leonhard Preis <leonhard@pre.is>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36466 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbCOHfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 03:35:50 -0400
Received: by lamx15 with SMTP id x15so17683790lam.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 00:35:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <op.xvifrvrh5ica7l@skepsis.pre.is>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 12:05:45AM +0100, Leonhard Preis wrote:
> Hi!
>=20
> iproute2=E2=80=99s ip utility fails to execute commands properly if o=
ne specifies
> any of the four device names h, he, hel, and help and only prints out=
 usage
> information.
>=20
> Expected behaviour for a non-existing device:
>=20
> % ip link show dev hello
> :(
> Device "hello" does not exist.
>=20
> Expected behaviour for an existing device:
>=20
> % ip link show dev lo
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN m=
ode
> DEFAULT group default
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>=20
> Behaviour observed for both existing and absent devices called either=
 h, he,
> hel or help:
>=20
> % ip link show dev hel
> :(
> Usage: ip link add [link DEV] [ name ] NAME
>                    [ txqueuelen PACKETS ]
>                    [ address LLADDR ]
>                    [ broadcast LLADDR ]
>                    [ mtu MTU ] [index IDX ]
>                    [ numtxqueues QUEUE_COUNT ]
>                    [ numrxqueues QUEUE_COUNT ]
>                    type TYPE [ ARGS ]
>        ip link delete DEV type TYPE [ ARGS ]
>=20
>        ip link set { dev DEVICE | group DEVGROUP } [ { up | down } ]
> 	                  [ arp { on | off } ]
> 	                  [ dynamic { on | off } ]
> 	                  [ multicast { on | off } ]
> 	                  [ allmulticast { on | off } ]
> 	                  [ promisc { on | off } ]
> 	                  [ trailers { on | off } ]
> 	                  [ txqueuelen PACKETS ]
> 	                  [ name NEWNAME ]
> 	                  [ address LLADDR ]
> 	                  [ broadcast LLADDR ]
> 	                  [ mtu MTU ]
> 	                  [ netns PID ]
> 	                  [ netns NAME ]
> 			  [ alias NAME ]
> 	                  [ vf NUM [ mac LLADDR ]
> 				   [ vlan VLANID [ qos VLAN-QOS ] ]
> 				   [ rate TXRATE ] ]
> 				   [ spoofchk { on | off} ] ]
> 				   [ state { auto | enable | disable} ] ]
> 			  [ master DEVICE ]
> 			  [ nomaster ]
> 			  [ addrgenmode { eui64 | none } ]
>        ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type =
TYPE]
>        ip link help [ TYPE ]
>=20
> TYPE :=3D { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |
>           bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |
>           gre | gretap | ip6gre | ip6gretap | vti | nlmon |
>           bond_slave }
>=20
> I successfully reproduced this on Debian Wheezy (iproute2 version
> 3.16.0-2~bpo70+1) and Arch Linux (iproute2 version 3.19.0-1).
>=20
> While the general origin of this problem seems quite clear, I=E2=80=99=
m left to
> wonder whether this is on purpose or not. Since I did not hit any oth=
er
> obstacles with the device name I chose I came to the conclusion that =
this
> may be a bug and it would be terrific if it could be fixed. For now I=
=E2=80=99ll
> perhaps simply change my device name - another l at the end will do t=
he job.
> ;)
>=20
> Please let me know if I could be of any further assistance or if this=
 report
> is missing vital information.
>=20
> Thank you!
>=20
> Cheers,
> Leonhard
>=20
> PS: I read in another thread that this mailing list is the "bug track=
er" for
> iproute2. I hope that statement is still true. It was my best shot at=
 the
> correct bug tracker.
>=20
> --=20
> Mit freundlichen Gr=C3=BC=C3=9Fen // Avec mes meilleures salutations =
// Best Regards
> Leonhard Preis
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

Would you be able to test the fix if I send a path in the email ?

Thanks,
