From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 00/10] ftgmac: Rework batch 2 - RX path
Date: Thu,  6 Apr 2017 11:02:42 +1000
Message-ID: <20170406010252.29208-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37896 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753160AbdDFBC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:02:59 -0400
Received: from pasglop.ozlabs.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3612slf029914
        for <netdev@vger.kernel.org>; Wed, 5 Apr 2017 20:02:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second batch of updates to the ftgmac100 driver.

This one tackles the RX path of the driver, simplifying
it greatly to match common practice while significantly
increasing the performance.

(The bulk of the performance gains of my series will be
provided by the TX path improvements, notably fragmented
sends, these will be in the next batch).
