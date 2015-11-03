From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v2 net-next 0/5] dp83640 driver fixes
Date: Tue, 3 Nov 2015 09:34:03 +0100
Message-ID: <1446539648-8355-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0103.outbound.protection.outlook.com ([157.56.110.103]:14512
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754122AbbKCIe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 03:34:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes a number of minor bugs in the dp83640 driver.

Stefan S=C3=B8rensen (5):
  dp83640: Include hash in timestamp/packet matching
  dp83640: Delay scheduled work.
  dp83640: Prune rx timestamp list before reading from it
  ptp: Change ptp_class to a proper bitmask
  dp83640: Only wait for timestamps for packets with timestamping
    enabled.

 drivers/net/phy/dp83640.c    | 64 ++++++++++++++++++++++++++++--------=
--------
 include/linux/ptp_classify.h |  7 ++---
 net/core/ptp_classifier.c    | 16 +++++------
 3 files changed, 53 insertions(+), 34 deletions(-)

v2 changes: Use macro for hash data offset and length and reword commit
description.

--=20
2.5.0
