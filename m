From: Victor NOEL <victor.noel@crazydwarves.org>
Subject: Re: zd1211rw (2.6.26.5) and ipv6
Date: Fri, 19 Sep 2008 16:12:29 +0200
Message-ID: <20080919141229.GA1177@crazydwarves.org>
References: <20080916175008.GR4610@crazydwarves.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crazydwarves.org ([82.233.236.81]:51421 "HELO
	mail.crazydwarves.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750709AbYISOMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 10:12:33 -0400
Content-Disposition: inline
In-Reply-To: <20080916175008.GR4610@crazydwarves.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

It looks like no one is interested in this, but I found something
else about this problem and maybe this will interest someone :)

I find a way to make it work : when I do, for example, a ping6
www.kame.net, like I said, nothing happens, but if, at the same
time, in another terminal I run "tcpdump -i wlan0 ip6" to see=20
what is happening, then the ping6 just starts to work !

This is the output of tcpdump :

[root@pistache ~]# sudo tcpdump -i wlan0 ip6
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on wlan0, link-type EN10MB (Ethernet), capture size 96 bytes
16:04:47.536006 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b > orange.kame.ne=
t: ICMP6, echo request, seq 1, length 64
16:04:47.822294 IP6 fe80::207:cbff:fec8:d1d2 > ff02::1:ff94:fd9b: ICMP6, ne=
ighbor solicitation, who has 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b, length=
 32
16:04:47.822354 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b > fe80::207:cbff=
:fec8:d1d2: ICMP6, neighbor advertisement, tgt is 2a01:e35:2f1f:8f10:b9ba:8=
c7f:1694:fd9b, length 32
16:04:47.824741 IP6 orange.kame.net > 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9=
b: ICMP6, echo reply, seq 1, length 64
16:04:48.537505 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b > orange.kame.ne=
t: ICMP6, echo request, seq 2, length 64
16:04:48.827362 IP6 orange.kame.net > 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9=
b: ICMP6, echo reply, seq 2, length 64
16:04:49.544169 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b > orange.kame.ne=
t: ICMP6, echo request, seq 3, length 64
16:04:49.827156 IP6 orange.kame.net > 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9=
b: ICMP6, echo reply, seq 3, length 64
16:04:50.547500 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b > orange.kame.ne=
t: ICMP6, echo request, seq 4, length 64
16:04:50.559867 IP6 unassigned.v6.your.org.www > 2a01:e35:2f1f:8f10:b9ba:8c=
7f:1694:fd9b.57536: S 2533693637:2533693637(0) ack 305690881 win 65535 <mss=
 1420,nop,wscale 3,sackOK,timestamp 3194396694 3902515>
16:04:50.559934 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b.57536 > unassign=
ed.v6.your.org.www: . ack 1 win 89 <nop,nop,timestamp 3905252 3194396694>
16:04:50.560084 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b.57536 > unassign=
ed.v6.your.org.www: P 1:448(447) ack 1 win 89 <nop,nop,timestamp 3905252 31=
94396694>
16:04:50.695772 IP6 unassigned.v6.your.org.www > 2a01:e35:2f1f:8f10:b9ba:8c=
7f:1694:fd9b.57536: . 1:1409(1408) ack 448 win 8272 <nop,nop,timestamp 3194=
426830 3905252>
16:04:50.695841 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b.57536 > unassign=
ed.v6.your.org.www: . ack 1409 win 133 <nop,nop,timestamp 3905293 319442683=
0>
16:04:50.696446 IP6 unassigned.v6.your.org.www > 2a01:e35:2f1f:8f10:b9ba:8c=
7f:1694:fd9b.57536: . 1409:2817(1408) ack 448 win 8272 <nop,nop,timestamp 3=
194426830 3905252>
16:04:50.696598 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b.57536 > unassign=
ed.v6.your.org.www: . ack 2817 win 177 <nop,nop,timestamp 3905293 319442683=
0>
16:04:50.832040 IP6 unassigned.v6.your.org.www > 2a01:e35:2f1f:8f10:b9ba:8c=
7f:1694:fd9b.57536: P 2817:3845(1028) ack 448 win 8272 <nop,nop,timestamp 3=
194426967 3905293>
16:04:50.832076 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b.57536 > unassign=
ed.v6.your.org.www: . ack 3845 win 221 <nop,nop,timestamp 3905334 319442696=
7>
16:04:50.851750 IP6 orange.kame.net > 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9=
b: ICMP6, echo reply, seq 4, length 64
16:04:51.550846 IP6 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9b > orange.kame.ne=
t: ICMP6, echo request, seq 5, length 64
16:04:51.850061 IP6 orange.kame.net > 2a01:e35:2f1f:8f10:b9ba:8c7f:1694:fd9=
b: ICMP6, echo reply, seq 5, length 64
^C
21 packets captured
21 packets received by filter
0 packets dropped by kernel

Thanks you for your help,

Victor

On Tue, Sep 16, 2008 at 07:50:08PM +0200, Victor NOEL wrote:
> Hello,
>=20
> After a little investigation (see after), I came to the conclusion
> there was something strange with the zd1211rw wifi driver (or
> maybe mac80211-based ones like it happened in the past ?) and ipv6
> (at least with autoconfiguration).
>=20
> I am on Archlinux with kernel 2.6.26.5 kernel behind a router
> connecting me to internet by ipv4 and ipv6.
>=20
> After a little discussion with John W. Linville on irc, he
> redirected me to this mailing list.
>=20
> The idea is that I connect to a wireless network with wpa
> protection, get my ipv4 address by dhcp and my ipv6 address by
> autoconfiguration : the ip is ok, the routes are goods, I can
> ping6 myself, I can ping6 the router (the next hop for default
> route) but I can't go out of this network.
>=20
> If I do the same but with ethernet (same router serving both
> ethernet and wifi), all the ip configuration, routes, neighbors
> are the same, but I can go out on the net.
>=20
> Nothing in dmesg.
>=20
> Of course ipv6 works on other boxes (I tried a windows on a
> laptop, and the routes used are the same too)
>=20
> This is what I have with both ethernet and wifi :
> First wifi :
> [victor@pistache ~]$ ip -6 route
> 2a01:e35:2f1f:8f10::/64 dev wlan0  proto kernel  metric 256 expires 86386=
sec mtu 1480 advmss 1420 hoplimit 4294967295
> fe80::/64 dev wlan0  metric 256  mtu 1480 advmss 1420 hoplimit 4294967295=
                                            =20
> default via fe80::207:cbff:fec8:d1d2 dev wlan0  proto kernel metric 1024 =
 expires 1797sec mtu 1480 advmss 1420 hoplimit 64
>=20
> [victor@pistache ~]$ ifconfig
> lo        Link encap:Local Loopback                                      =
                                               =20
>           inet addr:127.0.0.1  Mask:255.0.0.0                            =
                                               =20
>           inet6 addr: ::1/128 Scope:Host                                 =
                                               =20
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1                       =
                                               =20
>           RX packets:12 errors:0 dropped:0 overruns:0 frame:0            =
                                               =20
>           TX packets:12 errors:0 dropped:0 overruns:0 carrier:0          =
                                               =20
>           collisions:0 txqueuelen:0
>           RX bytes:748 (748.0 b)  TX bytes:748 (748.0 b)
>=20
> wlan0     Link encap:Ethernet  HWaddr 00:60:B3:EA:19:97
>           inet addr:192.168.0.1  Bcast:192.168.0.255 Mask:255.255.255.0
>           inet6 addr: 2a01:e35:2f1f:8f10:5:2b83:18cf:89f1/64 Scope:Global
>           inet6 addr: 2a01:e35:2f1f:8f10:260:b3ff:feea:1997/64 Scope:Glob=
al
>           inet6 addr: fe80::260:b3ff:feea:1997/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:18242 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:19472 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:16047994 (15.3 Mb)  TX bytes:2862642 (2.7 Mb)
>=20
> wmaster0  Link encap:UNSPEC  HWaddr 00-60-B3-EA-19-97-00-00-00-00-00-00-0=
0-00-00-00
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
> [victor@pistache ~]$ ping6 www.kame.net
> PING www.kame.net(orange.kame.net) 56 data bytes
> ^C
> --- www.kame.net ping statistics ---
> 5 packets transmitted, 0 received, 100% packet loss, time 4011ms
>=20
> [victor@pistache ~]$ tracepath6 www.kame.net
>  1?: [LOCALHOST]                      pmtu 1480
>  1:  no reply
> ^C
>=20
> [victor@pistache ~]$ ip -6 neigh show
> fe80::207:cbff:fec8:d1d2 dev wlan0 lladdr 00:07:cb:c8:d1:d2 router STALE
>=20
>=20
> And ethernet :
> [victor@pistache ~]$ ifconfig
> eth0      Link encap:Ethernet  HWaddr 00:0E:A6:AA:D4:55
>           inet addr:192.168.0.21  Bcast:192.168.0.255 Mask:255.255.255.0
>           inet6 addr: 2a01:e35:2f1f:8f10:20e:a6ff:feaa:d455/64 Scope:Glob=
al
>           inet6 addr: fe80::20e:a6ff:feaa:d455/64 Scope:Link
>           inet6 addr: 2a01:e35:2f1f:8f10:c8bc:d444:cd3:ca45/64 Scope:Glob=
al
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:6 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:36 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1548 (1.5 Kb)  TX bytes:7671 (7.4 Kb)
>           Interrupt:22
>=20
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           inet6 addr: ::1/128 Scope:Host
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:12 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:748 (748.0 b)  TX bytes:748 (748.0 b)
>=20
> [victor@pistache ~]$ ip -6 route
> 2a01:e35:2f1f:8f10::/64 dev eth0  proto kernel  metric 256 expires 86369s=
ec mtu 1480 advmss 1420 hoplimit 4294967295
> fe80::/64 dev eth0  metric 256  mtu 1480 advmss 1420 hoplimit 4294967295
> default via fe80::207:cbff:fec8:d1d2 dev eth0  proto kernel metric 1024  =
expires 1780sec mtu 1480 advmss 1420 hoplimit 64
>=20
> [victor@pistache ~]$ ping6 www.kame.net
> PING www.kame.net(orange.kame.net) 56 data bytes
> 64 bytes from orange.kame.net: icmp_seq=3D1 ttl=3D50 time=3D283 ms
> ^C
> --- www.kame.net ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev =3D 283.337/283.337/283.337/0.000 ms
>=20
> [victor@pistache ~]$ tracepath6 www.kame.net
>  1?: [LOCALHOST]                      pmtu 1480
>  1:  2a01:e35:2f1f:8f10::1                      1.078ms
>  2:  6to4-b8-e3.intf.routers.proxad.net        30.465ms
>  3:  bzn-crs16-1-te1-1-0-7.intf.routers.proxad.net  32.224ms
>  4:  2001:5a0:0:300::25                        31.212ms
>  5:  2001:5a0:0:300::2a                       107.376ms
>  6:  if-1-0.core2.nto-newyork.ipv6.teleglobe.net 108.126ms
>  7:  p16-0-1-1.r20.nycmny01.us.bb.gin.ntt.net asymm  8 107.843ms
> ^C
>=20
> [victor@pistache ~]$ ip -6 neigh show
> fe80::207:cbff:fec8:d1d2 dev eth0 lladdr 00:07:cb:c8:d1:d2 router STALE
>=20
> That's all for now, I hope nothing is missing.
>=20
> Thanks you for your help,
>=20
> Victor



--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFI07NNQ7uDv7gIkeURAm2KAJ9DVKK/EGyANJoiDYraTIey+JIIXACeNxPO
I9AKHspILRMCXjRPSjOwWuQ=
=Sc1n
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--
