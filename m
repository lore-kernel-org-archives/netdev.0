From: David Ahern <dsa@cumulusnetworks.com>
Subject: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Fri, 14 Apr 2017 16:23:22 -0600
Message-ID: <0c7198e6-7dde-917b-9c10-4e1835e38319@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Robert Shearman <rshearma@brocade.com>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35370 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751371AbdDNWXY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 18:23:24 -0400
Received: by mail-pf0-f180.google.com with SMTP id i5so45036498pfc.2
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 15:23:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subash:

My understanding of early demux is that it should only match connected
sockets (src/sport + dst/dport are all set). The ipv6 udp early demux
code added in 5425077d73e0c is doing a generic socket lookup which does
not require an exact match and accordingly breaks udp_l3mdev_accept=0.
Please fix.

David
