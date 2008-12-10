From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Loopback and non-Ethernet protocols
Date: Wed, 10 Dec 2008 16:18:15 +0200
Message-ID: <200812101618.15448.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:48415 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbYLJOSW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 09:18:22 -0500
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBAEIDL4028846
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 08:18:20 -0600
Received: from esdhcp041160.research.nokia.com (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBAEIFDK031618
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 16:18:16 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

lo claims to be an Ethernet device. Especially, the use of eth_type_tra=
ns() in=20
the TX callback appears to prevent conveying non-Ethernet packet types.
Is there a preferred way to loop back such packets?

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
