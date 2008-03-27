From: Toralf =?iso-8859-15?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: tx-checksumming for an Intel Corporation 82540EP Gigabit Ethernet Controller (Mobile)
Date: Thu, 27 Mar 2008 11:44:52 +0100
Message-ID: <200803271144.52812.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:49557 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751805AbYC0Ko4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 06:44:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm wondering why I have to add this line in my startup scripts :=20

$> /usr/sbin/ethtool -K eth0 tx off
to avoid that all outgoing packets have bad check sums (seen with wires=
hark).

Wouldn't it makes sense to make this behaviour as default ?

My system is a ThinkPad T41:

n22 ~ # uname -a
Linux n22 2.6.24-gentoo-r3 #5 Tue Mar 18 19:26:55 CET 2008 i686 Intel(R=
) Pentium(R) M processor 1700MHz GenuineIntel GNU/Linux

Pls response to my address too b/c I'm not currently subscribed.

--=20
MfG/Sincerely

Toralf F=F6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
