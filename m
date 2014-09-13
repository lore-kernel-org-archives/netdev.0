From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCHv3 net-next 0/3] sunvnet: add jumbo frames support
Date: Sat, 13 Sep 2014 12:00:27 -0400
Message-ID: <54146A1B.8060207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23820 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbaIMQAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 12:00:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set updates the sunvnet driver to version 1.6 of the VIO protocol
to support per-port exchange of MTU information and allow non-standard MTU
sizes, including jumbo frames.

Using large MTUs shows a > 4X throughput improvement Linux-Solaris
and > 8X throughput improvement Linux-Linux.

Changes from v2:
	- make checkpatch clean
Changes from v1:
	- fix brace formatting per Dave Miller <davem@davemloft.net>

David L Stevens (3):
  sunvnet: upgrade to VIO protocol version 1.6
  sunvnet: allow admin to set sunvnet MTU
  sunvnet: generate ICMP PTMUD messages for smaller port MTUs

 arch/sparc/include/asm/vio.h       |   19 ++++-
 arch/sparc/kernel/viohs.c          |   14 +++-
 drivers/net/ethernet/sun/sunvnet.c |  143 +++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sun/sunvnet.h |    1 +
 4 files changed, 154 insertions(+), 23 deletions(-)
