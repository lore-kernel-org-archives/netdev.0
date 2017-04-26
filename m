From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Move sub crq init out of interrupt context
Date: Wed, 26 Apr 2017 14:49:31 -0400 (EDT)
Message-ID: <20170426.144931.2181011396838839496.davem@davemloft.net>
References: <20170425185704.41126.65738.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965346AbdDZStd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:49:33 -0400
In-Reply-To: <20170425185704.41126.65738.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Tue, 25 Apr 2017 15:00:58 -0400

> The sub crqs are currently intialized in interrupt context when
> handling a crq response fromn the vios server. There is no reason
> they must be initialized there.
> 
> Moving the initialization of the sub crqs to the ibmvnic_init routine
> allows us to do the initialization outside of interrupt context and
> make all of the allocations with GFP_KERNEL instead of GFP_ATOMIC.

Series applied, thanks.
