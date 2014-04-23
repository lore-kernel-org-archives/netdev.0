From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 0/2] iproute2: can: support CAN FD control interface
Date: Wed, 23 Apr 2014 19:27:25 +0200
Message-ID: <1398274047-5407-1-git-send-email-socketcan@hartkopp.net>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:18605 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757670AbaDWR14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 13:27:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For CAN FD a new set of bittiming configuration and enabling functions for the
data section is provided by the CAN driver infrastructure.

This patch set allows to configure the newly introduced CAN FD properties.

Tested with PEAK PCAN USB pro FD pilot series hardware.

Oliver Hartkopp (2):
  iproute2: can: fix indention white spaces
  iproute2: can: support CAN FD control interface

 ip/iplink_can.c | 144 +++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 107 insertions(+), 37 deletions(-)

-- 
1.9.2
