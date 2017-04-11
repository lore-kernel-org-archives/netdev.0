From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/2] l2tp: drop l2tp_session_find()
Date: Tue, 11 Apr 2017 13:12:03 +0200
Message-ID: <cover.1491908878.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:58702 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdDKLMG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 07:12:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_netlink is the last user of l2tp_session_find(), but that call is
useless. Let's remove it and drop l2tp_session_find() definitely.

Guillaume Nault (2):
  l2tp: remove useless duplicate session detection in l2tp_netlink
  l2tp: remove l2tp_session_find()

 net/l2tp/l2tp_core.c    | 51 +------------------------------------------------
 net/l2tp/l2tp_core.h    |  3 ---
 net/l2tp/l2tp_netlink.c |  5 -----
 3 files changed, 1 insertion(+), 58 deletions(-)

-- 
2.11.0
