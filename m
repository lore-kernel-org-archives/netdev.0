From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Return from ibmvnic_resume if not in
 VNIC_OPEN state
Date: Tue, 20 Jun 2017 15:17:20 -0400 (EDT)
Message-ID: <20170620.151720.500309763541776829.davem@davemloft.net>
References: <b9b5f82f-c59b-4816-b745-31080c6cdf78@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751002AbdFTTRV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:17:21 -0400
In-Reply-To: <b9b5f82f-c59b-4816-b745-31080c6cdf78@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Mon, 19 Jun 2017 11:27:53 -0500

> If the ibmvnic driver is not in the VNIC_OPEN state, return from
> ibmvnic_resume callback. If we are not in the VNIC_OPEN state, interrupts
> may not be initialized and directly calling the interrupt handler will
> cause a crash.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Applied.
