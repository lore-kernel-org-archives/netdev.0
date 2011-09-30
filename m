From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 0/4] be2net: fixes
Date: Fri, 30 Sep 2011 22:52:09 +0530
Message-ID: <4bdbbef6-24f6-432f-9642-99ce7887f52d@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:10146 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755678Ab1I3MAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 08:00:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply

Somnath Kotur (4):
  be2net: Change the data type of the 'on die temperature' stat.
  be2net: Fixed Endianness issues in the response read log length field
    while retrieving FAT data
  be2net: Modified PCI MaxReadReq size to 4096 bytes
  be2net: Making die temperature ioctl call async

 drivers/net/ethernet/emulex/benet/be.h      |    7 ++++-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   42 ++++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +
 3 files changed, 34 insertions(+), 17 deletions(-)
