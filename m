From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/11] ibmvnic: Updated reset handler and
 code fixes
Date: Tue, 02 May 2017 15:49:21 -0400 (EDT)
Message-ID: <20170502.154921.1597219817832466075.davem@davemloft.net>
References: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbdEBTtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:49:23 -0400
In-Reply-To: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Tue, 02 May 2017 14:52:11 -0400

> This set of patches multiple code fixes and a new rest handler
> for the ibmvnic driver. In order to implement the new reset handler
> for the ibmvnic driver resource initialization needed to be moved to
> its own routine, a state variable is introduced to replace the
> various is_* flags in the driver, and a new routine to handle the
> assorted reasons the driver can be reset.
> 
> v3 updates:
> 
> Patch 10/11: Correct patch subject line to be a description of the patch.
> 
> v2 updates:
> 
> Patch 11/11: Use __netif_subqueue_stopped() instead of
> netif_subqueue_stopped() to avoid possible use of an un-initialized
> skb variable.

Your patches have trailing whitespace errors, please fix:

Applying: ibmvnic: Move resource initialization to its own routine
Applying: ibmvnic: Replace is_closed with state field
Applying: ibmvnic: Updated reset handling
/home/davem/src/GIT/net-next/.git/rebase-apply/patch:104: trailing whitespace.
	
warning: 1 line adds whitespace errors.
Applying: ibmvnic: Delete napi's when releasing driver resources
Applying: ibmvnic: Whitespace correction in release_rx_pools
Applying: ibmvnic: Clean up tx pools when closing
Applying: ibmvnic: Wait for any pending scrqs entries at driver close
/home/davem/src/GIT/net-next/.git/rebase-apply/patch:68: trailing whitespace.
	
warning: 1 line adds whitespace errors.
Applying: ibmvnic: Check for driver reset first in ibmvnic_xmit
Applying: ibmvnic: Continue skb processing after skb completion error
Applying: ibmvnic: Record SKB RX queue during poll
Applying: ibmvnic: Move queue restarting in ibmvnic_tx_complete
