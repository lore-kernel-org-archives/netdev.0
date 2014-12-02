From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 0/6] sunvnet: add SG, HW_CSUM, GSO, and TSO support
Date: Tue, 02 Dec 2014 15:30:39 -0500
Message-ID: <547E216F.4000307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30763 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbaLBUao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:30:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds everything needed for TSO support in sunvnet. On my
test hardware, this increases the single-stream TCP throughput for the
default 1500-byte MTU Linux-Linux from ~2Gbps to 10Gbps and Linux-Solaris
from ~2Gbps to 6Gbps.

David L Stevens (6):
  sunvnet: rename vnet_port_alloc_tx_bufs and move after version
    negotiation
  sunvnet: add VIO v1.7 and v1.8 support
  sunvnet: add scatter/gather support
  sunvnet: add checksum offload support
  sunvnet: add GSO support
  sunvnet: add TSO support

 arch/sparc/include/asm/vio.h       |   19 ++
 drivers/net/ethernet/sun/sunvnet.c |  406 ++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sun/sunvnet.h |    9 +-
 3 files changed, 388 insertions(+), 46 deletions(-)
