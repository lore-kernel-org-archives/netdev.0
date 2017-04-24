From: David Miller <davem@davemloft.net>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Mon, 24 Apr 2017 11:10:28 -0400 (EDT)
Message-ID: <20170424.111028.2157290275229080747.davem@davemloft.net>
References: <1492785652578.53801@Dell.com>
        <20170424075606.GA19926@gondor.apana.org.au>
        <1493046084156.78287@Dell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, Clifford.Wichmann@dell.com,
        netdev@vger.kernel.org
To: Joe.Ghalam@dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49900 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936253AbdDXPKa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:10:30 -0400
In-Reply-To: <1493046084156.78287@Dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Joe.Ghalam@dell.com>
Date: Mon, 24 Apr 2017 15:01:24 +0000

>> The only thing that can stop macvlan_process_broadcast from getting
>> called is macvlan_port_destroy.  Nothing else can stop the work
>> queue, unless of course the work queue mechanism itself is broken.
> 
>> So if you're sure macvlan_port_destroy is never even called in
>> your case, then you'll need to start debugging the kernel work
>> queue mechanism to see why macvlan_process_broadcast is not getting
>> called.
> 
> I will get your changes reloaded and re-tested without any other debug tools. Hopefully, we'll see success. I will let you know if I see any issues. 
> Btw, is your fix committed already? if not, do you know when and where it would be committed?

I'm waiting for this discussion to settle down before I apply the
patch.
