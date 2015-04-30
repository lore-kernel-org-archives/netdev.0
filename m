From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH v2 net-next 0/3] tcp: SACK RTTM changes for congestion control
Date: Fri,  1 May 2015 01:10:56 +0200
Message-ID: <1430435459-12805-1-git-send-email-kennetkl@ifi.uio.no>
Cc: ycheng@google.com, Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:58890 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbbD3XLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 19:11:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series improves SACK RTT measurements for congestion control:
  o Picks the latest sequence SACKed for RTT, i.e. most accurate delay
    signal.
  o Calls the congestion control's pkts_acked hook with SACK RTTMs
    even when not sequentially ACKing new data.

V2: amend misleading comment

Kenneth Klette Jonassen (3):
  tcp: move struct tcp_sacktag_state to tcp_ack()
  tcp: improve RTT from SACK for CC
  tcp: invoke pkts_acked hook on every ACK

 net/ipv4/tcp_input.c | 86 ++++++++++++++++++++++++++--------------------------
 1 file changed, 43 insertions(+), 43 deletions(-)

-- 
2.1.0
