From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix a request socket leak
Date: Fri, 08 Sep 2017 16:08:14 -0700 (PDT)
Message-ID: <20170908.160814.574433719450434783.davem@davemloft.net>
References: <1504899887.15310.95.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170908225921.bxbgaldzt5fslpda@ast-mbp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757242AbdIHXIS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 19:08:18 -0400
In-Reply-To: <20170908225921.bxbgaldzt5fslpda@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Fri, 8 Sep 2017 15:59:23 -0700

> On Fri, Sep 08, 2017 at 12:44:47PM -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> While the cited commit fixed a possible deadlock, it added a leak
>> of the request socket, since reqsk_put() must be called if the BPF
>> filter decided the ACK packet must be dropped.
>> 
>> Fixes: d624d276d1dd ("tcp: fix possible deadlock in TCP stack vs BPF filter")
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>> David, this is a stable candidate (linux-4.13 has this bug)
> 
> Thanks for the fix
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> .. since the fix makes sense to me and as a reminder not to forget
> to backport it as well :)

Applied and queued up for -stable.
