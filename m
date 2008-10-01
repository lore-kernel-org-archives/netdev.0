From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 0/6] [RFC] Phonet pipes protocol (v2)
Date: Wed, 1 Oct 2008 13:12:17 +0300
Message-ID: <200810011312.17288.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:59039 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbYJAKNQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 06:13:16 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m91ACe1a024958
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 13:13:13 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello again,

This patchset adds the Phonet pipe (end-point) protocol, without
missing patches nor dummy debug. This protocols provides some
connection handling and negotiated congestion control. It's used as a
generic protocol for bulk transfers with Nokia cellular modems.

The penultimate patch provides virtual IP interface support on top of a
connected Phonet pipe socket. This is used for IP over GPRS.
The implementation uses sock callbacks internally and socket options
toward userland. Not sure if this is the "right" way.

 Documentation/networking/phonet.txt |   54 +
 include/linux/phonet.h              |   12
 include/linux/socket.h              |    1
 include/net/phonet/gprs.h           |   38 +
 include/net/phonet/pep.h            |  156 ++++
 net/phonet/Makefile                 |    6
 net/phonet/af_phonet.c              |    8
 net/phonet/pep-gprs.c               |  341 ++++++++++
 net/phonet/pep.c                    | 1126 +++++++++++++++++++++++++++=
++++++++-
 net/phonet/socket.c                 |  109 +++
 10 files changed, 1816 insertions(+), 35 deletions(-)


Sorry for the noise

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
