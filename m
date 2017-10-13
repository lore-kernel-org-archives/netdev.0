From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 0/2] Minor macvlan source mode cleanups
Date: Fri, 13 Oct 2017 13:40:18 -0700
Message-ID: <20171013203726.16950.32584.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:49027 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751851AbdJMUkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 16:40:20 -0400
Received: by mail-pf0-f196.google.com with SMTP id b79so11260162pfk.5
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 13:40:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So this patch series is just a few minor cleanups for macvlan source mode.
The first patch addresses double receives when a packet is being routed to
the macvlan destination address, and the other addresses the pkt_type being
updated in cases where it most likely should not be.

---

Alexander Duyck (2):
      macvlan: Only deliver one copy of the frame to the macvlan interface
      macvlan: Only update pkt_type if destination MAC address matches


 drivers/net/macvlan.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)
