From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header,Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header,Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header,Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Thu, 13 Oct 2016 11:57:08 -0400 (EDT)
Message-ID: <20161013.115708.2077879944453283228.davem@davemloft.net>
References: <20ace6ee-b9e4-073c-56e7-29b2c50ae2d5@redhat.com>
        <20161013.104314.1842951254979604965.davem@davemloft.net>
        <2eadc083-e2e0-5c6d-fe84-c5851be3e2ec@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, linux-rdma@vger.kernel.org,
        sean.hefty@intel.com, hal.rosenstock@gmail.com,
        netdev@vger.kernel.org
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34570 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755258AbcJMP7W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 11:59:22 -0400
In-Reply-To: <2eadc083-e2e0-5c6d-fe84-c5851be3e2ec@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Ledford <dledford@redhat.com>
Date: Thu, 13 Oct 2016 11:20:59 -0400

> We *had* a safe way to do that.  It got broken.  What about increasing
> the size of skb->cb?  Or adding a skb->dgid that is a
> u8[INFINIBAND_ALEN]?  Or a more generic skb->dest_ll_addr that is sized
> to hold the dest address for any link layer?

I understand the situation, and I also believe that making sk_buff any
huger than it already is happens to be a non-starter.

>> Pushing metadata before the head of the SKB data pointer is illegal,
>> as the layers in between might want to push protocol headers,
> 
> That's a total non-issue for us.  There are no headers that protocols
> can add before ours.

Ok, if that's the case, and based upon Paolo's response to me it appears
to be, I guess this is OK for now.

Paolo please resubmit your patch, thanks.
