From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 0/2] netfilter: ,netdev@vger.kernel.org
Date: Tue, 21 Mar 2017 18:53:17 +0530
Message-ID: <1490102599-27579-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com,
        wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34726 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932499AbdCUNXX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:23:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series Simplify function returns by merging 
assignment and return into one command line.

simran singhal (2):
  netfilter: ipset: Compress return logic
  netfilter: ipvs: Compress return logic

 net/netfilter/ipset/ip_set_list_set.c | 5 +----
 net/netfilter/ipvs/ip_vs_ftp.c        | 5 +----
 2 files changed, 2 insertions(+), 8 deletions(-)

-- 
2.7.4
