From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Thu, 06 Apr 2017 12:38:36 -0700 (PDT)
Message-ID: <20170406.123836.2076491695651167803.davem@davemloft.net>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbdDFTip (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:38:45 -0400
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed,  5 Apr 2017 12:28:40 +1000

> This is version 2 of the first batch of updates to the
> ftgmac100 driver.
> 
> Essentially:
> 
>  - A few misc cleanups
>  - Fixing link speed & duplex handling (including dealing with
>    an Aspeed requirement to double reset the controller when
>    the speed changes)
>  - And addition of a reset task workqueue which will be used
>    for delaying the re-initialization of the controller
>  - Fixing a number of issues with how interrupts and NAPI
>    are dealt with.
> 
> Subsequent batches will rework and improve the rx path, the
> tx path, and add a bunch of features and fixes.
> 
> Version 2 addresses some review comments to patches 5 and 10
> (see version history in the respective emails).

Series applied.
