From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 0/8] ftgmac100: Rework batch 5 - Features
Date: Thu, 13 Apr 2017 08:44:35 +1000
Message-ID: <20170412224443.17906-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33706 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752851AbdDLWoy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 18:44:54 -0400
Received: from pasglop.au.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3CMijM8029786
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 17:44:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is fifth and last batch of updates to the ftgmac100 driver.

This contains a few additional "features" such as:

 - Support for ethtool n-way reset
 - Multicast filtering & promisc support
 - Vlan offload
 - netpoll

And a couple of misc bits. This also adds the device-tree binding
documentation.
