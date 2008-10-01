From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 0/4] [RFC] Phonet pipe protocol
Date: Wed, 1 Oct 2008 11:21:14 +0300
Message-ID: <200810011121.14746.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:20064 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbYJAIVy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 04:21:54 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m918LWPX000303
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 11:21:51 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

This patchset adds the Phonet pipe (end-point) protocol. This protocols
provides some connection handling and negotiated congestion control. It=
's used
as a generic protocol for bulk transfers with Nokia cellular modems.

The third patch provides virtual IP interface support on top of a
connected Phonet pipe socket. This is used for IP over GPRS.
The implementation uses sock callbacks internally and socket options as
the userland API. Not sure if this is the "right" way.

 Documentation/networking/phonet.txt |   54 +
 include/linux/phonet.h              |   12
 include/linux/socket.h              |    1
 include/net/phonet/gprs.h           |   38 +
 include/net/phonet/pep.h            |  118 +++
 net/phonet/Makefile                 |    6
 net/phonet/af_phonet.c              |    3
 net/phonet/pep-gprs.c               |  345 ++++++++++
 net/phonet/pep.c                    | 1136 +++++++++++++++++++++++++++=
++++++++-
 net/phonet/socket.c                 |   14
 10 files changed, 1689 insertions(+), 38 deletions(-)

=46eedback welcome.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
