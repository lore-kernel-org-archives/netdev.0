From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net 0/2] sfc: couple of fixes
Date: Fri, 3 Mar 2017 15:20:44 +0000
Message-ID: <0750d060-35d1-c221-f866-fba825e3947e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:53848 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752227AbdCCPVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 10:21:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch addresses a construct that causes sparse to error out.
With that fixed, sparse makes some warnings on ef10.c, second patch
 fixes one of them.

Edward Cree (2):
  sfc: avoid max() in array size
  sfc: fix IPID endianness in TSOv2

 drivers/net/ethernet/sfc/ef10.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)
