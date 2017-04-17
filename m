From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v3 0/9] ftgmac100: Rework batch 5 - Features
Date: Tue, 18 Apr 2017 08:36:57 +1000
Message-ID: <20170417223706.16483-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55993 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753862AbdDQWhR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 18:37:17 -0400
Received: from pasglop.au.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v3HMbCOX026691
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 17:37:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the third spin of the fifth and last batch of
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

v3. - Rebase on net-next (fix conflict with an unrelated #include
      change series)
    - Update DT bindings better describing accepted phy-mode values
