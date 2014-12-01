From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 0/3] timestamping updates
Date: Sun, 30 Nov 2014 22:22:32 -0500
Message-ID: <1417404155-28607-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:55222 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbaLADWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 22:22:38 -0500
Received: by mail-yh0-f53.google.com with SMTP id i57so4461261yha.12
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 19:22:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The main goal for this patchset is to allow correlating timestamps
with the egress interface. Also introduce a warning, as discussed
previously, and update the tests to verify the new feature.

Willem de Bruijn (3):
  ipv4: warn once on passing AF_INET6 socket to ip_recv_error
  net-timestamp: allow reading recv cmsg on errqueue with origin tstamp
  net-timestamp: expand documentation and test

 Documentation/networking/timestamping.txt          | 33 ++++++--
 .../networking/timestamping/txtimestamp.c          | 90 +++++++++++++++++++---
 include/uapi/linux/net_tstamp.h                    |  3 +-
 net/ipv4/ip_sockglue.c                             | 24 +++++-
 net/ipv6/datagram.c                                | 21 ++++-
 5 files changed, 146 insertions(+), 25 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
