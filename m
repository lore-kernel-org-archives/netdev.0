From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 0/2] l2tp: fix error handling of PPPoL2TP socket options
Date: Thu, 6 Apr 2017 18:31:18 +0200
Message-ID: <cover.1491495941.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60538 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752592AbdDFQbW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 12:31:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix pppol2tp_[gs]etsockopt() so that they don't ignore errors returned
by their helper functions.

Guillaume Nault (2):
  l2tp: don't mask errors in pppol2tp_setsockopt()
  l2tp: don't mask errors in pppol2tp_getsockopt()

 net/l2tp/l2tp_ppp.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

-- 
2.11.0
