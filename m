From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] net: ipv6: simplify rt6_fill_node
Date: Tue, 17 Jan 2017 15:51:06 -0800
Message-ID: <1484697068-20106-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33025 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdAQXvO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:51:14 -0500
Received: by mail-pg0-f42.google.com with SMTP id 204so28426160pge.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 15:51:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a couple of unnecessary input arguments to rt6_fill_node.

David Ahern (2):
  net: ipv6: remove nowait arg to rt6_fill_node
  net: ipv6: remove prefix arg to rt6_fill_node

 include/linux/mroute6.h |  2 +-
 net/ipv6/ip6mr.c        |  9 ++-------
 net/ipv6/route.c        | 46 ++++++++++++++++++----------------------------
 3 files changed, 21 insertions(+), 36 deletions(-)

-- 
2.1.4
