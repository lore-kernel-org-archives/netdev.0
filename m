From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 00/10] ftgmac100: Rework batch 4 - Misc
Date: Wed, 12 Apr 2017 13:27:00 +1000
Message-ID: <20170412032710.17546-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41839 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751992AbdDLD1W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:27:22 -0400
Received: from pasglop.ozlabs.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3C3RJYZ022256
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 22:27:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v2 of the fourth batch of updates to the ftgmac100 driver.

This is a bunch of misc cleanups and fixes, such as properly
disabling HW checksum generation on AST2400 where it's known
to be broken and some chip init updates.

This also adds the ability to turn HW checksum on/off and
configure the ring sizes via ethtool.

v2 Fixes patch 1/10 (NETIF_F_HW_CSUM conversion)

The next (and last) batch will add a few more "features" such
as netpoll, multicast/promist, vlan offload...
