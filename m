From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net] ibmvnic: Fix overflowing firmware/hardware TX
 queue
Date: Tue, 07 Mar 2017 14:14:44 -0800 (PST)
Message-ID: <20170307.141444.1814957653636898496.davem@davemloft.net>
References: <1488737922-17305-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com, wvoigt@us.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756217AbdCGWPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:15:47 -0500
In-Reply-To: <1488737922-17305-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Sun,  5 Mar 2017 12:18:41 -0600

> Use a counter to track the number of outstanding transmissions sent
> that have not received completions. If the counter reaches the maximum
> number of queue entries, stop transmissions on that queue. As we receive 
> more completions from firmware, wake the queue once the counter reaches 
> an acceptable level.
> 
> This patch prevents hardware/firmware TX queue from filling up and
> and generating errors.  Since incorporating this fix, internal testing
> has reported that these firmware errors have stopped.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
