From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] amd-xgbe: Interrupt summary bits are h/w
 version dependent
Date: Tue, 29 Aug 2017 15:31:24 -0700 (PDT)
Message-ID: <20170829.153124.564367562949459434.davem@davemloft.net>
References: <20170828202934.17073.940.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdH2WbZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 18:31:25 -0400
In-Reply-To: <20170828202934.17073.940.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 28 Aug 2017 15:29:34 -0500

> There is a difference in the bit position of the normal interrupt summary
> enable (NIE) and abnormal interrupt summary enable (AIE) between revisions
> of the hardware.  For older revisions the NIE and AIE bits are positions
> 16 and 15 respectively.  For newer revisions the NIE and AIE bits are
> positions 15 and 14.  The effect in changing the bit position is that
> newer hardware won't receive AIE interrupts in the current version of the
> driver.  Specifically, the driver uses this interrupt to collect
> statistics on when a receive buffer unavailable event occurs and to
> restart the driver/device when a fatal bus error occurs.
> 
> Update the driver to set the interrupt enable bit based on the reported
> version of the hardware.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied.
