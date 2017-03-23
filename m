From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Fix the ECC-related bit position
 definitions
Date: Wed, 22 Mar 2017 19:40:26 -0700 (PDT)
Message-ID: <20170322.194026.565756067458106431.davem@davemloft.net>
References: <20170322222526.10361.35455.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756109AbdCWCk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:40:28 -0400
In-Reply-To: <20170322222526.10361.35455.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 22 Mar 2017 17:25:27 -0500

> The ECC bit positions that describe whether the ECC interrupt is for
> Tx, Rx or descriptor memory and whether the it is a single correctable
> or double detected error were defined in incorrectly (reversed order).
> Fix the bit position definitions for these settings so that the proper
> ECC handling is performed.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
> 
> Please queue this patch up for 4.10-stable.

Applied and queued up for -stable, thanks.
