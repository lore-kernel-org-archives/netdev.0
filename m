From: Tilman Schmidt <tilman@imap.cc>
Subject: Q: State of Linux RSTP support
Date: Wed, 24 Sep 2014 20:00:02 +0200
Message-ID: <542306A2.7020008@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38449 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134AbaIXR74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 13:59:56 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id A356A20740
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 13:59:55 -0400 (EDT)
Received: from [192.168.59.117] (unknown [93.232.233.163])
	by mail.messagingengine.com (Postfix) with ESMTPA id 19B46C00919
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 13:59:54 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

According to Stephen Hemminger's presentation at
http://www.slideshare.net/shemminger/new-bridge (which seems to be the
most recent information available on the topic) the in-kernel bridging
code only provides STP. RTSP is (should be) provided by a user space
daemon, rtspd. However, none of the distributions I routinely use
provide that daemon. Sourceforge has a project named rstpd but it
seems to be inactive.

A search for RSTP in the current git tree finds

- - in net/bridge/br_netlink.c, a comment:
                      /* Binary compatibility with old RSTP */

- - in net/bridge/br_private.h, an enum constant for struct net_bridge
member stp_enabled:
              BR_USER_STP,            /* new RSTP in userspace */

but nothing in, say, the Documentation folder.

Any pointers?

aTdHvAaNnKcSe,
Tilman

- --=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUIwaiAAoJEFPuqx0v+F+q/dIIAI8tK2C7yVPoD3PaLwwVqcxQ
9lV3VCXiRT4v1fGTqEtzTJhoyPAqZw+iHbmoPVZow9GPEAS1m5nPYBE44cejmP6M
SL0OtQmcnYO0UNBsIpwA6F8g+e3ZraivtAv4CVoBLMXGWrAz7zrERIRTkk0XOMdG
t2Is1e+U+48DlOH8CIPhqOEu/kIABz2GMle5S94VzlBkeBsGL9ifDrFxACtxbkEN
YJIm9QKxZa/MGwksgHCoQWDafrcs8RL6FhQDBVCUVhrERlp/12+kKwYXxvH9kv+a
YAAzMXkAu+3zPTI0Bl99M4NEQ57Z0FKtb8pwug9wSKH7UWdx18pKYOsYUdMwROM=3D
=3Ds37Z
-----END PGP SIGNATURE-----
