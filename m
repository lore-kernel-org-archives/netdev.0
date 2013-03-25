From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 0/3] ipv4: Fix ip-header identification for gso packets.
Date: Sun, 24 Mar 2013 20:36:07 -0700
Message-ID: <1364182567-1667-1-git-send-email-pshelar@nicira.com>
Cc: amwang@redhat.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:58644 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756524Ab3CYDhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:37:13 -0400
Received: by mail-pb0-f72.google.com with SMTP id rp2so1219210pbb.11
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 20:37:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch fixes ip-header identification according to comments from
David Miller and Cong Wang.
First two patches reverts fixes to upper layer gso handlers which is not
required after fixing ipv4 gso handler.

Pravin B Shelar (3):
  Revert "ip_gre: increase inner ip header ID during segmentation"
  Revert "udp: increase inner ip header ID during segmentation"
  ipv4: Fix ip-header identification for gso packets.

 include/net/ipip.h |   16 ++++++----------
 net/ipv4/af_inet.c |    3 +--
 net/ipv4/gre.c     |    7 +------
 net/ipv4/udp.c     |    7 +------
 4 files changed, 9 insertions(+), 24 deletions(-)
