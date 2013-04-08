From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Subject: 3.9-rc6 (only) one particular tap device putted into forwarding state
Date: Mon, 08 Apr 2013 21:03:51 +0200
Message-ID: <51631497.4070103@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I realized these new syslog messages at a 32 bit stable Gentoo, which h=
ave
4 configured TAP devices attached to a bridge :

2013-04-08T19:55:20.048+02:00 n22 kernel: br0: port 4(tap3) entered for=
warding state
2013-04-08T19:55:20.048+02:00 n22 kernel: br0: port 4(tap3) entered for=
warding state
2013-04-08T19:55:20.316+02:00 n22 kernel: br0: port 4(tap3) entered dis=
abled state

This happened one time only and only for one device (for tap3, and all =
4 devices are identical configured)
for one boot attempt till now - no configuration were changed.


--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
