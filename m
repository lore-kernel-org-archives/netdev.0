From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Start completion queue negotiation at
 server-provided optimum values
Date: Wed, 09 Nov 2016 18:52:55 -0500 (EST)
Message-ID: <20161109.185255.1523462856860673479.davem@davemloft.net>
References: <7d5c1364-7167-8d69-d9d4-bc89d19f8457@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752167AbcKIXw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:52:58 -0500
In-Reply-To: <7d5c1364-7167-8d69-d9d4-bc89d19f8457@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Mon, 7 Nov 2016 14:27:28 -0600

> Use the opt_* fields to determine the starting point for negotiating the
> number of tx/rx completion queues with the vnic server. These contain the
> number of queues that the vnic server estimates that it will be able to
> allocate. While renegotiation may still occur, using the opt_* fields will
> reduce the number of times this needs to happen and will prevent driver
> probe timeout on systems using large numbers of ibmvnic client devices per
> vnic port.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Applied, thanks.
