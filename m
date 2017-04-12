From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 0/2] l2tp: constify l2tp_session_get*() and
 l2tp_tunnel_find*()
Date: Wed, 12 Apr 2017 10:05:28 +0200
Message-ID: <cover.1491984104.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:37816 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdDLIFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 04:05:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare parameters of these functions as "const" where possible.

Guillaume Nault (2):
  l2tp: define parameters of l2tp_session_get*() as "const"
  l2tp: define parameters of l2tp_tunnel_find*() as "const"

 net/l2tp/l2tp_core.c | 11 ++++++-----
 net/l2tp/l2tp_core.h |  9 +++++----
 2 files changed, 11 insertions(+), 9 deletions(-)

-- 
2.11.0
