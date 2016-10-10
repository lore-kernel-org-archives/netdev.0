From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 0/2] conntrack update
Date: Mon, 10 Oct 2016 12:18:22 +0200
Message-ID: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        fw@strlen.de
To: davem@davemloft.net, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38663 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751976AbcJJKS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 06:18:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch is a small documentation fix.
The second patch adds more flexibility to configure the conntrack gc. I target
it specifically to net and not net-next because the removal of the conntrack
timer has just land into net.

 Documentation/networking/nf_conntrack-sysctl.txt | 35 +++++++++++------------
 include/net/netfilter/nf_conntrack_core.h        |  5 ++++
 net/netfilter/nf_conntrack_core.c                | 17 +++++------
 net/netfilter/nf_conntrack_standalone.c          | 36 ++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 26 deletions(-)

Comments are welcomed,
Regards,
Nicolas
