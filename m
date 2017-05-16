From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 14:52:49 -0400 (EDT)
Message-ID: <20170516.145249.871010194359061722.davem@davemloft.net>
References: <1494955244.3259.130.camel@redhat.com>
        <20170516.133644.850927380166261577.davem@davemloft.net>
        <1494957802.3259.131.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Bart.VanAssche@sandisk.com, torvalds@linux-foundation.org,
        hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752941AbdEPSw6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 14:52:58 -0400
In-Reply-To: <1494957802.3259.131.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Ledford <dledford@redhat.com>
Date: Tue, 16 May 2017 14:03:22 -0400

> On Tue, 2017-05-16 at 13:36 -0400, David Miller wrote:
>> From: Doug Ledford <dledford@redhat.com>
>> Date: Tue, 16 May 2017 13:20:44 -0400
>> 
>> > Anyway, we're just talking out what happened, when what we really
>> need
>> > to focus on is moving forward.  Again, your thoughts on marking SMC
>> > EXPERIMENTAL until it's fixed up and unfreezing the API in case we
>> need
>> > to adjust it to work on different link layers?
>> 
>> Something like:
>> 
>>         http://patchwork.ozlabs.org/patch/762803/
>> 
>> with the addition of the EXPERIMENTAL dependency?
>> 
>> Sure.
> 
> Perfect.  I assume you'll submit it since it's in your patchworks?

Ok I applied the patch referenced above, but we don't actually have
an EXPERIMENTAL symbol.  The closest thing we have is BROKEN and
even in this situation that's a bit harsh.

I also applied the patch which converts SMC over to using
IB_PD_UNSAFE_GLOBAL_RKEY.
