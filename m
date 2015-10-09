From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v4 0/2] fix tunnel statistics handling
Date: Fri,  9 Oct 2015 11:27:36 +0200
Message-ID: <1444382858-6725-1-git-send-email-aschultz@tpip.net>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:55696 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965020AbbJIJ1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 05:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are the two changes I send earlier, rebased to net-next to avoid
a merge conflict. The statistics bug they fix has been noted before, so
I can wait a bit longer in net-next.

This first patch changes to the return of iptunnel_xmit to return the
real err value when err < 0. Before the return value would always be >= 0.

The second patch fixes the error handling of iptunnel_xmit in tipc.

Andreas Schultz (2):
  fix return of iptunnel_xmit
  tipc: remove invalid ip_rt_put

 net/ipv4/ip_tunnel_core.c | 9 ++++++---
 net/tipc/udp_media.c      | 4 ----
 2 files changed, 6 insertions(+), 7 deletions(-)

-- 
2.1.4
