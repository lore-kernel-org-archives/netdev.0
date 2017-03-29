From: Varsha Rao <rvarsha016@gmail.com>
Subject: [PATCH 0/2] net: ipv4: Use DIV_ROUND_UP and BIT macros.
Date: Thu, 30 Mar 2017 00:43:30 +0530
Message-ID: <58dc0766.15cc630a.ea2e9.5274@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: outreachy-kernel <outreachy-kernel@googlegroups.com>,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35248 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752656AbdC2TNn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 15:13:43 -0400
Received: by mail-pg0-f66.google.com with SMTP id g2so4047552pge.2
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 12:13:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset uses DIV_ROUND_UP and BIT macros to simplify computations
in tcp_bbr.c file.

Varsha Rao (2):
  net: ipv4: Use DIV_ROUND_UP macro.
  net: ipv4: Use BIT macro.

 net/ipv4/tcp_bbr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
2.9.3
