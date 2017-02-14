From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ibmvnic: Fix initial MTU settings
Date: Tue, 14 Feb 2017 14:58:10 -0500 (EST)
Message-ID: <20170214.145810.826153305226199095.davem@davemloft.net>
References: <1487089379-29498-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754778AbdBNT6M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:58:12 -0500
In-Reply-To: <1487089379-29498-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2017 10:22:59 -0600

> In the current driver, the MTU is set to the maximum value
> capable for the backing device. This decision turned out to
> be a mistake as it led to confusion among users. The expected
> initial MTU value used for other IBM vNIC capable operating
> systems is 1500, with the maximum value (9000) reserved for
> when Jumbo frames are enabled. This patch sets the MTU to
> the default value for a net device.
> 
> It also corrects a discrepancy between MTU values received from
> firmware, which includes the ethernet header length, and net
> device MTU values.
> 
> Finally, it removes redundant min/max MTU assignments after device
> initialization.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> ---
> v2: included more detailed commit message addressing why
>     this patch is needed

Applied, thanks.
