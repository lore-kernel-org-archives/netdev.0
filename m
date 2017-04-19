From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-04-19
Date: Wed, 19 Apr 2017 07:10:34 +0200
Message-ID: <1492578636-621-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:40808 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759552AbdDSFPk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 01:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two fixes for af_key:

1) Add a lock to key dump to prevent a NULL pointer dereference.
   From Yuejie Shi.

2) Fix slab-out-of-bounds in parse_ipsecrequests.
   From Herbert Xu.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 75514b6654859e0130b512396dc964d2a9e84967:

  net: ethernet: ti: cpsw: wake tx queues on ndo_tx_timeout (2017-04-02 19:42:44 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 096f41d3a8fcbb8dde7f71379b1ca85fe213eded:

  af_key: Fix sadb_x_ipsecrequest parsing (2017-04-18 08:26:03 +0200)

----------------------------------------------------------------
Herbert Xu (1):
      af_key: Fix sadb_x_ipsecrequest parsing

Yuejie Shi (1):
      af_key: Add lock to key dump

 net/key/af_key.c | 93 ++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 64 insertions(+), 29 deletions(-)
