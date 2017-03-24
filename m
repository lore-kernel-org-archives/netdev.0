From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] net: mpls: multipath route cleanups
Date: Fri, 24 Mar 2017 15:21:55 -0700
Message-ID: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com>
Cc: rshearma@brocade.com, roopa@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33800 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935137AbdCXWWJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 18:22:09 -0400
Received: by mail-pf0-f174.google.com with SMTP id p189so1402487pfp.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 15:22:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a device associated with a nexthop is deleted, the nexthop in
the route is effectively removed, so remove it from the route dump.

Further, when all nexhops have been deleted the route is effectively
done, so remove the route. 

David Ahern (2):
  mpls: Don't show nexthop if device has been deleted
  mpls: Delete route when all nexthops have been deleted

 net/mpls/af_mpls.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

-- 
2.1.4
