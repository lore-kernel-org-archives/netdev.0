From: Peter Bieringer <pb@bieringer.de>
Subject: IPv6 MTU of a tunnel: 2 different switches, which wins?
Date: Mon, 02 Sep 2002 09:10:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <10010000.1030950619@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

sure here anyone can help me:

Let's say I have an internet connection via PPPoE through ppp0/eth1

MTU eth1: 1500
MTU ppp0: 1492

Over this connection, an IPv6 (named tun6to4) tunnel will be
established. Now I have 2 different switches to adjust the MTU of the
tunnel.

a) using utility ip
b) using sysctl

After unmodified MTU setup:

a)
# ip link show dev tun6to4 | grep -w mtu
42: tun6to4@NONE: <NOARP,UP> mtu 1480 qdisc noqueue

b)
# sysctl -a| grep tun6to4 | grep mtu
net.ipv6.conf.tun6to4.mtu = 1480

But proper MTU will be

MTU tun6to4: 1472   MTU(ppp0) - 20 for IPv4 header


where to proper set now?

1) via ip
2) via sysctl in net.ipv6.conf.tun6to4.mtu
3) both switches

BTW: host should act either as router or standalone.


Thanks for any clarifies,

        Peter


---
Dr. Peter Bieringer
mailto: pb at bieringer dot de
http://www.bieringer.de/pb/
Key 0x958F422D : B501 24F4 9418 23E2 C0F3  F833 7B57 AA7B 958F 422D

-- Attached file included as plaintext by Ecartis --

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)

iD8DBQE9cw7ce1eqe5WPQi0RAt7BAKDbIkoPEImZ0lhlzSadipAn7AsZlACff1Cs
Ap2x3BNiHfIxe6/sD7lqxDU=
=8Ya4
-----END PGP SIGNATURE-----
