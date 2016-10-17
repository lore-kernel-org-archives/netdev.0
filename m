From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH V2 RFC 0/2] ixgbe: ixgbe_atr() bug fixes
Date: Mon, 17 Oct 2016 10:25:05 -0700
Message-ID: <cover.1476724638.git.sowmini.varadhan@oracle.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: sowmini.varadhan@oracle.com, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18082 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938542AbcJQRZY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:25:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two bug fixes:
- ixgbe_atr() should check for protocol == udp in the
  skb->encapsulation case (instead of !=)
- ixgbe_atr() should make sure the non-paged data has the
  needed network/transport header for computing l4_proto.

Sowmini Varadhan (2):
  ixgbe: ixgbe_atr() should access udp_hdr(skb) only for UDP packets
  ixgbe: ixgbe_atr() compute l4_proto only if non-paged data has
    network/transport headers

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)
