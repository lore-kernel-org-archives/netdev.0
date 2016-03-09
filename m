From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 0/2] A couple of minor clean-ups and
 optimizations
Date: Wed, 09 Mar 2016 09:22:48 -0800
Message-ID: <20160309171924.11477.93179.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33912 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933506AbcCIRWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:22:55 -0500
Received: by mail-pa0-f49.google.com with SMTP id fe3so28747805pab.1
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 09:22:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is basically just a v2 of a couple patches I recently
submitted.

The two patches aren't technically related but there are just items I found
while cleaning up and prepping some further work to enable Tx checksums for
tunnels.

---

Alexander Duyck (2):
      gro: Defer clearing of flush bit in tunnel paths
      csum: Update csum_block_add to use rotate instead of byteswap


 drivers/net/geneve.c   |    7 ++-----
 drivers/net/vxlan.c    |    3 +--
 include/net/checksum.h |   12 ++++++------
 net/ipv4/fou.c         |    3 +--
 net/ipv4/gre_offload.c |    3 +--
 5 files changed, 11 insertions(+), 17 deletions(-)
