From: William Tu <u9012063@gmail.com>
Subject: [net-next 0/3] ip_gre: a bunch of fixes for mtu
Date: Mon,  9 Oct 2017 13:47:44 -0700
Message-ID: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38055 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754188AbdJIUsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 16:48:03 -0400
Received: by mail-pf0-f196.google.com with SMTP id a7so30359207pfj.5
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 13:48:03 -0700 (PDT)
Received: from sc9-mailhost3.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id p71sm17861098pfl.56.2017.10.09.13.48.01
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 13:48:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first two patches are to fix some issues for mtu and needed_headroom length
calculation from the gre and erspan tunnel header.  The last path tries to avoid
arithmetic operation for every packet when checking for erspan truncate.

William Tu (3):
  ip_gre: fix mtu and headroom size
  ip_gre: fix erspan tunnel mtu calculation
  ip_gre: cache the device mtu hard_header_len calc

 include/net/erspan.h     |  1 +
 include/net/ip_tunnels.h |  1 +
 net/ipv4/ip_gre.c        | 23 +++++++++++------------
 net/ipv4/ip_tunnel.c     |  3 +++
 4 files changed, 16 insertions(+), 12 deletions(-)

-- 
2.7.4
