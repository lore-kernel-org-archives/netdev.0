From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net,stable 0/2] Fixes for PPPoL2TP sockets
Date: Wed, 12 Jun 2013 16:07:10 +0200
Message-ID: <20130612140710.GA3500@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34848 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753181Ab3FLONP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 10:13:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here are two fixes for the PPPoL2TP sendmsg() call:

  -Patch 1 fixes an skbuff management issue.
  -Patch 2 updates the value returned to userspace on success.
   Though it's a userspace visible change, I submit it because
   (1) it fixes a compliance issue with a standardised interface,
   (2) sendmsg() wasn't functional anyway before applying patch 1,
       so fixing its return value shouldn't hurt any existing program.

Regards,

Guillaume Nault (2):
  l2tp: Fix PPP header erasure and memory leak
  l2tp: Fix sendmsg() return value

 net/l2tp/l2tp_ppp.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
1.7.10.4
