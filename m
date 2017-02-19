From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Handle processing of CRQ messages in a
 tasklet
Date: Sun, 19 Feb 2017 18:12:59 -0500 (EST)
Message-ID: <20170219.181259.2160741684232396660.davem@davemloft.net>
References: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54632 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751126AbdBSXNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 18:13:01 -0500
In-Reply-To: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 15 Feb 2017 12:17:58 -0600

> Create a tasklet to process queued commands or messages received from
> firmware instead of processing them in the interrupt handler. Note that
> this handler does not process network traffic, but communications related
> to resource allocation and device settings.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.

Can you _please_ in the future submit a series of changes as a proper
numbered patch series with a proper "[PATCH 0/N] " header posting instead
listing explicitly X, Y and Z dependencies?

Thanks.
