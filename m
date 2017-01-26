From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/5] ibmvnic: Fix MTU settings
Date: Wed, 25 Jan 2017 23:05:04 -0500 (EST)
Message-ID: <20170125.230504.215468934911959234.davem@davemloft.net>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <1485378143-5084-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        wvoigt@us.ibm.com, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55096 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdAZEFF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 23:05:05 -0500
In-Reply-To: <1485378143-5084-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 25 Jan 2017 15:02:20 -0600

> In the current driver, the MTU is set to the maximum value
> capable for the backing device. This patch sets the MTU to the
> default value for a Linux net device.

Why are you doing this?

What happens to users who depend upon the current behavior.

They will break, and that isn't acceptable.
