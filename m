From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net-next 0/6] Phonet improvements
Date: Fri, 23 Jan 2009 14:59:29 +0200
Message-ID: <200901231459.29743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:37462 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837AbZAWM7Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 07:59:24 -0500
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n0NCxDh3017172
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 06:59:21 -0600
Received: from leon.remlab.net (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n0NCxF4L027805
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 14:59:15 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

There come a few fixes and cleanups of the Phonet stack.
Comments welcome.

Diff stat:
 include/net/phonet/phonet.h |    1
 include/net/phonet/pn_dev.h |    7 +-
 net/Kconfig                 |    2
 net/phonet/af_phonet.c      |   29 +++++-----
 net/phonet/pn_dev.c         |  127 +++++++++++++++++++++++++++++------=
---------
 net/phonet/pn_netlink.c     |   24 ++++----
 6 files changed, 119 insertions(+), 71 deletions(-)

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

