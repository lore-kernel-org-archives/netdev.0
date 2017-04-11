From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 00/10] ftgmac100: Rework batch 4 - Misc
Date: Tue, 11 Apr 2017 11:04:26 +1000
Message-ID: <20170411010436.23290-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39756 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751932AbdDKBEr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 21:04:47 -0400
Received: from pasglop.ozlabs.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3B14bgF025949
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 20:04:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the fourth batch of updates to the ftgmac100 driver.

This is a bunch of misc cleanups and fixes, such as properly
disabling HW checksum generation on AST2400 where it's known
to be broken and some chip init updates.

This also adds the ability to turn HW checksum on/off and
configure the ring sizes via ethtool.

The next (and last) batch will add a few more "features" such
as netpoll, multicast/promist, vlan offload...
