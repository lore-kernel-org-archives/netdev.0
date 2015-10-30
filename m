From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 0/5] dp83640 driver fixes
Date: Fri, 30 Oct 2015 13:13:59 +0100
Message-ID: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0136.outbound.protection.outlook.com ([157.56.111.136]:31710
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752372AbbJ3M3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 08:29:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes a number of minor bugs in the dp83640 driver.=20

Stefan S=C3=B8rensen (5):
  dp83640: Include hash in timestamp/packet matching
  dp83640: Delay scheduled work.
  dp83640: Prune rx timestamp list before reading from it
  ptp: Change ptp_class to a proper bitmask
  dp83640: Only wait for timestamps for packets with timestamping enabl=
ed.

 drivers/net/phy/dp83640.c    | 60 +++++++++++++++++++++++++++---------=
--------
 include/linux/ptp_classify.h |  7 +++---
 net/core/ptp_classifier.c    | 16 ++++++------
 3 files changed, 49 insertions(+), 34 deletions(-)

--=20
2.5.0
