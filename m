From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Fix IRQ processing when running in
 single IRQ mode
Date: Fri, 06 Jan 2017 15:34:26 -0500 (EST)
Message-ID: <20170106.153426.727385787329515187.davem@davemloft.net>
References: <20170104210716.8401.99717.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938097AbdAFUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:34:27 -0500
In-Reply-To: <20170104210716.8401.99717.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 4 Jan 2017 15:07:16 -0600

> When running in single IRQ mode, the additional IRQ routines were being
> skipped because only the XGMAC interrupt status was being checked.
> Update the code so that the additional IRQ routines are checked whenever
> an interrupt is received.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied.
