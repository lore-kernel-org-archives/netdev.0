From: Marcin Kaminski <maxiu@man.poznan.pl>
Subject: socket(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6)
Date: Wed, 12 Mar 2003 13:17:47 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0303121313240.17866-100000@rose.man.poznan.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

I've found, that on my system (2.2.22) RAW sockets for IPv6 works
different than for IPv4.
When I create socket like:
    interfaceSocket =3D socket(PF_INET, SOCK_RAW, IPPROTO_ICMP);
I receive ICMPv4 packets with IP header, but when I use
    interfaceSocket =3D socket(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
I receive ICMPv6 packets WITHOUT IPv6 header.
What should I do in order to get full packet?
Man pages of raw(7) tell:

For receiving the IP header is always included in the packet.

But it is not true for IPv6 :(

With regards
- Marcin Kaminski --------------------------------- maxiu -
--- software developer ------------------- 6net project ---
----- network administrator -------- Best Group admin -----
------- Pozna=F1 Supercomputing and Networking Center -------
