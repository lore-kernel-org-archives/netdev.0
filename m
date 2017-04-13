From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 0/9] ftgmac100: Rework batch 5 - Features
Date: Thu, 13 Apr 2017 14:39:07 +1000
Message-ID: <20170413043916.7793-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58904 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750775AbdDMEj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 00:39:28 -0400
Received: from pasglop.ozlabs.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3D4dO9h023336
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 23:39:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second spin of the fifth and last batch of
updates to the ftgmac100 driver.

This contains a few additional "features" such as:

 - Support for ethtool n-way reset
 - Multicast filtering & promisc support
 - Vlan offload
 - netpoll

And a couple of misc bits. This also adds the device-tree binding
documentation.

v2. - Addresses review comments and adds a new patch fixing a
      theorical ordering issue in my new NAPI poll implementation
    - Add a bug fix (Patch 8/9) for a potential ordering issue
      in the new NAPI poll code.
