From: =?ISO-8859-1?Q?An=EDbal_Almeida_Pinto?= <anibal.pinto@efacec.com>
Subject: [RFC] micrel KSZ8041 disable auto negotiation with fiber
Date: Tue, 19 Jun 2012 15:45:59 +0100
Message-ID: <4FE090A7.801@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.efacec.com ([62.28.144.243]:39495 "HELO mail2.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751750Ab2FSO7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 10:59:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am working on a custom board based on a OMAP L138 with a KSZ8041TL-FT=
L=20
phy that have fibber and copper support.

When using with fibber the board can't connect to a switch, only after=20
exec :

	ethtool -s eth1 speed 100 duplex full autoneg off

the phy get link and start working.

On some switches it appears that autoneg don't work well with fibber,=20
ethtool reports that its at 10MB/s after exec

	ethtool -s eth1 autoneg on

The auto negotiation bit on phy register is disable on start when using=
=20
the fibber but Linux don't appear to look at it.

=46ound a thread [1] that solve the problem but don't appear to be full=
y=20
accepted.

The problem is modifying the phy code without interfere with ethtool us=
e.

Any official/accepted solution to this problem ?

Thanks.

[1] - http://marc.info/?l=3Dlinuxppc-embedded&m=3D131107263711714

An=EDbal
