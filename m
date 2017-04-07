From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 00/12] ftgmac100: Rework batch 3 - TX path
Date: Fri,  7 Apr 2017 13:30:53 +1000
Message-ID: <20170407033105.29558-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54969 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751918AbdDGDbM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:12 -0400
Received: from pasglop.ozlabs.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v373V9Ch007254
        for <netdev@vger.kernel.org>; Thu, 6 Apr 2017 22:31:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the third batch of updates to the ftgmac100 driver.

This one tackles the TX path of the driver. This provides the
bulk of the performance improvements by adding support for
fragmented sends along with a bunch of cleanups.

Subsequent batches will add various features (ethtool functions,
vlan offlan, ...) and cleanups.
