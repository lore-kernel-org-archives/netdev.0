From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 0/4] CDC Phonet function fixes
Date: Mon, 6 Apr 2009 17:58:57 +0300
Message-ID: <200904061758.58057.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:53598 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbZDFO65 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 10:58:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

Here are a bunch of fixes for the Phonet USB gadget function network
interface driver. Comments welcome.

R=E9mi Denis-Courmont (4):
      f_phonet: dev_kfree_skb instead of dev_kfree_skb_any in TX callba=
ck
      f_phonet: no need to check for carrier - scheduler does it intern=
ally
      f_phonet: fix memory allocation sizes
      f_phonet: use page-sized rather than MTU-sized RX buffers

 drivers/usb/gadget/f_phonet.c |   95 +++++++++++++++++++++++++--------=
--------
 1 files changed, 58 insertions(+), 37 deletions(-)

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

