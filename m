From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v3 net-next 0/2] TPACKET_V3 TX_RING support
Date: Tue,  3 Jan 2017 06:31:46 -0800
Message-ID: <cover.1483452545.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33364 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750980AbdACOcW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 09:32:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series allows an application to use a single PF_PACKET
descriptor and leverage the best implementations of TX_RING
and RX_RING that exist today.

Patch 1 adds the kernel/Documentation changes for TX_RING
support and patch2 adds the associated test case in selftests.

Changes since v2: additional sanity checks for setsockopt
input for TX_RING/TPACKET_V3. Refactored psock_tpacket.c
test code to avoid code duplication from V2.


Sowmini Varadhan (2):
  af_packet: TX_RING support for TPACKET_V3
  tools: test case for TPACKET_V3/TX_RING support

 Documentation/networking/packet_mmap.txt    |    9 ++-
 net/packet/af_packet.c                      |   39 +++++++++---
 tools/testing/selftests/net/psock_tpacket.c |   91 ++++++++++++++++++++++-----
 3 files changed, 111 insertions(+), 28 deletions(-)
