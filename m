From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] net/sched fixes for cls_flower and act_tunnel_key
Date: Thu, 22 Dec 2016 14:28:13 +0200
Message-ID: <1482409695-27956-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58715 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965211AbcLVM2a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 07:28:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small series contain a fix to the matching flags support 
in flower and to the tunnel key action MD prep for IPv6.

On a non related note, wishing everyone around here a happy new year, 
celebrate and take a rest so we can do lots of good patch work(s) next.

Or.

Or Gerlitz (2):
  net/sched: act_tunnel_key: Fix setting UDP dst port in metadata under IPv6
  net/sched: cls_flower: Mandate mask when matching on flags

 net/sched/act_tunnel_key.c |  4 ++--
 net/sched/cls_flower.c     | 23 ++++++++++++-----------
 2 files changed, 14 insertions(+), 13 deletions(-)

-- 
2.3.7
