From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 0/3] sunvnet: add jumbo frames support
Date: Fri, 12 Sep 2014 18:22:05 -0400
Message-ID: <5413720D.9060202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39466 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647AbaILWWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 18:22:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set updates the sunvnet driver to version 1.6 of the VIO protocol
to support per-port exchange of MTU information and allow non-standard MTU
sizes, including jumbo frames.

Using large MTUs shows a > 4X throughput improvement Linux-Solaris
and > 8X throughput improvement Linux-Linux.

David L Stevens (3):
  sunvnet: upgrade to VIO protocol version 1.6
  sunvnet: allow admin to set sunvnet MTU
  sunvnet: generate ICMP PTMUD messages for smaller port MTUs

 arch/sparc/include/asm/vio.h       |   19 +++++-
 arch/sparc/kernel/viohs.c          |   14 +++-
 drivers/net/ethernet/sun/sunvnet.c |  137 +++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sun/sunvnet.h |    1 +
 4 files changed, 150 insertions(+), 21 deletions(-)
