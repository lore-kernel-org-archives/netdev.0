From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Wed,  5 Apr 2017 12:28:40 +1000
Message-ID: <20170405022853.8238-1-benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48164 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751166AbdDEC3U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 22:29:20 -0400
Received: from pasglop.ozlabs.ibm.com (localhost.localdomain [127.0.0.1])
        by gate.crashing.org (8.14.1/8.13.8) with ESMTP id v352T5op018378
        for <netdev@vger.kernel.org>; Tue, 4 Apr 2017 21:29:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is version 2 of the first batch of updates to the
ftgmac100 driver.

Essentially:

 - A few misc cleanups
 - Fixing link speed & duplex handling (including dealing with
   an Aspeed requirement to double reset the controller when
   the speed changes)
 - And addition of a reset task workqueue which will be used
   for delaying the re-initialization of the controller
 - Fixing a number of issues with how interrupts and NAPI
   are dealt with.

Subsequent batches will rework and improve the rx path, the
tx path, and add a bunch of features and fixes.

Version 2 addresses some review comments to patches 5 and 10
(see version history in the respective emails).
