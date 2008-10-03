From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 0/6] Phonet pipes protocol (take 3)
Date: Fri, 3 Oct 2008 17:09:11 +0300
Message-ID: <200810031709.11828.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:32113 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbYJCOJk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 10:09:40 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m93E9MYD013730
	for <netdev@vger.kernel.org>; Fri, 3 Oct 2008 17:09:38 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

This patchset adds the Phonet pipe (end-point) protocol, trying to inte=
grate
comments from the mailing list. This is a generic protocol for bulk tra=
nsfers
with existing Nokia cellular modems.

=A0Documentation/networking/phonet.txt | =A0 54 +
=A0include/linux/phonet.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 12
=A0include/linux/socket.h =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01
=A0include/net/phonet/gprs.h =A0 =A0 =A0 =A0 =A0 | =A0 38 +
=A0include/net/phonet/pep.h =A0 =A0 =A0 =A0 =A0 =A0| =A0156 ++++
=A0net/phonet/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06
=A0net/phonet/af_phonet.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A08
=A0net/phonet/pep-gprs.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0341 +++++++++=
+
=A0net/phonet/pep.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| 1126 +++++=
++++++++++++++++++++++++++++++-
=A0net/phonet/socket.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0109 +++
=A010 files changed, 1816 insertions(+), 35 deletions(-)

Best regards,

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
