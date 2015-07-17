From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 0/2] tcp: minor tail loss probe improvements
Date: Fri, 17 Jul 2015 14:22:50 -0700
Message-ID: <1437168172-24201-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33585 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbbGQVXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:23:13 -0400
Received: by padck2 with SMTP id ck2so66417110pad.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:23:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enhance the tail loss probe (TLP) to timeout
quicker if it fails to send a probe, and tries harder to send
a probe.

Yuchung Cheng (2):
  tcp: don't extend RTO on failed loss probe attempts
  tcp: TLP retransmits last if failed to send new packet

 net/ipv4/tcp_output.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

-- 
2.4.3.573.g4eafbef
