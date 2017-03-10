From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Enable IRQs only if napi_complete_done()
 is true
Date: Thu, 09 Mar 2017 18:31:47 -0800 (PST)
Message-ID: <20170309.183147.1115919481874028502.davem@davemloft.net>
References: <20170309234823.11010.87592.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeremy.linton@arm.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753648AbdCJCbu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 21:31:50 -0500
In-Reply-To: <20170309234823.11010.87592.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 9 Mar 2017 17:48:23 -0600

> Depending on the hardware, the amd-xgbe driver may use disable_irq_nosync()
> and enable_irq() when an interrupt is received to process Rx packets. If
> the napi_complete_done() return value isn't checked an unbalanced enable
> for the IRQ could result, generating a warning stack trace.
> 
> Update the driver to only enable interrupts if napi_complete_done() returns
> true.
> 
> Reported-by: Jeremy Linton <jeremy.linton@arm.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks.
