From: kuznet@ms2.inr.ac.ru
Subject: Re: raw ipv6 broken in 2.4.19
Date: Mon, 12 Aug 2002 23:20:56 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208121920.XAA18870@sex.inr.ac.ru>
References: <1029179259.791.31.camel@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: gandalf@wlug.westbo.se (Martin Josefsson)
In-Reply-To: <1029179259.791.31.camel@tux> from "Martin Josefsson" at Aug 12, 2 09:07:38 pm
List-Id: netdev.vger.kernel.org

Hello!

> raw ipv6 doesn't work in 2.4.19,

Seems, more information is required because of:

root@mops:~ # cat /proc/version
Linux version 2.4.20-pre1-mops (root@mops) (gcc version 3.0.2 20010905 (A=
SPLinux 7.2 3.0.1-3)) #3370 =F7=D4=D2 =E1=D7=C7 6 18:18:59 MSD 2002
root@mops:~ # traceroute6 sex
traceroute to sex.inr.ac.ru (3ffe:2400:0:5:202:b3ff:fe90:d922) from 3ffe:=
2400:0:4:240:d0ff:fe16:a83d, 30 hops max, 16 byte packets
 1  dust.inr.ac.ru (3ffe:2400:0:4:2c0:95ff:fee7:f562)  0.412 ms  0.195 ms=
  0.143 ms
 2  sex.inr.ac.ru (3ffe:2400:0:5:202:b3ff:fe90:d922)  0.216 ms  0.199 ms =
 0.207 ms
root@mops:~ # ping6 sex
PING sex(sex.inr.ac.ru) 56 data bytes
64 bytes from sex.inr.ac.ru: icmp_seq=3D1 ttl=3D63 time=3D0.218 ms
64 bytes from sex.inr.ac.ru: icmp_seq=3D2 ttl=3D63 time=3D0.229 ms
64 bytes from sex.inr.ac.ru: icmp_seq=3D3 ttl=3D63 time=3D0.206 ms
64 bytes from sex.inr.ac.ru: icmp_seq=3D4 ttl=3D63 time=3D0.223 ms

--- sex ping statistics ---
4 packets transmitted, 4 received, 0% loss, time 3030ms
rtt min/avg/max/mdev =3D 0.206/0.219/0.229/0.008 ms
root@mops:~ #

So, please, make binary tcpdumps and tell me version of iputils,
which you use and make straces of ping.

Alexey
