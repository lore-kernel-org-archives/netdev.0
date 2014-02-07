From: Wolfgang Walter <linux@stwm.de>
Subject: linux 3.13: problems with isatap tunnel device and UFO
Date: Fri, 07 Feb 2014 18:47:07 +0100
Message-ID: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:38916 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056AbaBGRxJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 12:53:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

with kernel 3.13 I have a problem with isatap tunnels receiving fragmen=
ted=20
ipv6 udp packets.

If I switch of ufo for the tunnel device the problem disappears:
	ethtool -K is0 ufo off

When UFO is on tcpdump shows the packets on the physical device but not=
 on the=20
tunnel device. The packets seem to be discarded.

With UFO off I can see them on is0 (and the packet is delivered to the=20
socket).

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
