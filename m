From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Check for transport event on driver
 resume
Date: Mon, 24 Jul 2017 17:40:20 -0700 (PDT)
Message-ID: <20170724.174020.2014851636629578869.davem@davemloft.net>
References: <9202073a-a9bb-5aa3-c6ea-3b16e35084db@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45492 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754809AbdGYAkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:40:21 -0400
In-Reply-To: <9202073a-a9bb-5aa3-c6ea-3b16e35084db@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Mon, 24 Jul 2017 13:26:06 -0500

> On resume, the ibmvnic driver will fail to resume normal operation.
> The main crq gets closed on suspend by the vnic server and doesn't get
> reopened again as the interrupt for the transport event that would reset
> the main crq comes in after the driver has been suspended.
> 
> This patch resolves the issue by removing the calls to kick the receive
> interrupts handlers and instead directly invoking the main crq interrupt
> handler. This will ensure that we see the transport event necessary to
> properly resume the driver.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Applied.
