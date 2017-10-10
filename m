From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: defer cgroups init to accept()
Date: Mon, 09 Oct 2017 20:55:27 -0700 (PDT)
Message-ID: <20171009.205527.1425793711119155761.davem@davemloft.net>
References: <20171009044452.20564-1-edumazet@google.com>
        <CANn89iKwxY8fiozVvRVhUTO14Cj_DBBoTHrEzYmPE2EwbZL8qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, hannes@cmpxchg.org,
        tj@kernel.org, jsperbeck@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755961AbdJJDz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 23:55:28 -0400
In-Reply-To: <CANn89iKwxY8fiozVvRVhUTO14Cj_DBBoTHrEzYmPE2EwbZL8qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun, 8 Oct 2017 21:47:49 -0700

> On Sun, Oct 8, 2017 at 9:44 PM, Eric Dumazet <edumazet@google.com> wrote:
>> After TCP 3WHS became lockless, we should not attempt cgroup games
>> from sk_clone_lock() since listener/cgroup might be already gone.
>>
>> Move this business to inet_csk_accept() where we have
>> the guarantee both parent and child exist.
>>
>> Many thanks to John Sperbeck for spotting these issues
>>
>> Eric Dumazet (2):
>>   net: memcontrol: defer call to mem_cgroup_sk_alloc()
>>   net: defer call to cgroup_sk_alloc()
> 
> This was based on net tree, but I used the wrong script, and thus this
> has the [PATCH net-next] tag.
> 
> Sorry for the confusion, but I guess this also can be applied to
> net-next since this is not a recent regression.

Series applied to 'net', thanks.
