From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [RFC] [PATCH 0/5] Phonet enhancements
Date: Wed, 17 Dec 2008 16:07:14 +0200
Message-ID: <200812171607.14184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:30888 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbYLQOHZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 09:07:25 -0500
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBHE71XN020330
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:07:21 +0200
Received: from esdhcp041160.research.nokia.com (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBHE7ER0016132
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:07:14 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

This simplifies the GPRS over Phonet virtual interface driver, and
adds support for a Phonet USB gadget (the latter will need to go
through linux-usb?). Comments welcome.

--
 drivers/usb/gadget/f_phonet.c |  621 +++++++++++++++++++++++++++++++++=
+++++++++
 drivers/usb/gadget/u_phonet.h |   21 +
 include/linux/if_arp.h        |    3
 include/net/phonet/pep.h      |    2
 net/core/dev.c                |   12
 net/phonet/pep-gprs.c         |   93 +-----
 net/phonet/pep.c              |   38 +-
 net/phonet/socket.c           |    2
 8 files changed, 703 insertions(+), 89 deletions(-)
--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
