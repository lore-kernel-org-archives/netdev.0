From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [IPROUTE2 0/2] Add ECN support to tc-netem
Date: Wed, 16 May 2012 16:51:56 -0700
Message-ID: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54331 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760721Ab2EPXua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 19:50:30 -0400
Received: by pbbrp8 with SMTP id rp8so1757917pbb.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 16:50:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent patch to net-next kernel from Eric Dumazet (e4ae004b84b netem: add ECN
capability) made it possible for netem to mark packets with ECN instead of
dropping them. These two patches add support to iproute2/tc and update the
manpage.

Vijay Subramanian (2):
  Update tc-netem manpage to add ecn capability
  tc-netem: Add support for ECN packet marking

 include/linux/pkt_sched.h |    1 +
 man/man8/tc-netem.8       |    8 ++++++--
 tc/q_netem.c              |   25 +++++++++++++++++++++++++
 3 files changed, 32 insertions(+), 2 deletions(-)
