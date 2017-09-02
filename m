From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] net: ubuf_info.refcnt conversion
Date: Fri, 01 Sep 2017 20:22:25 -0700 (PDT)
Message-ID: <20170901.202225.1965773132023198232.davem@davemloft.net>
References: <20170831234822.26612-1-edumazet@google.com>
        <1504224295.15310.17.camel@edumazet-glaptop3.roam.corp.google.com>
        <1504287389.15310.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdIBDWZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 23:22:25 -0400
In-Reply-To: <1504287389.15310.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Sep 2017 10:36:29 -0700

> On Thu, 2017-08-31 at 17:04 -0700, Eric Dumazet wrote:
>> On Thu, 2017-08-31 at 16:48 -0700, Eric Dumazet wrote:
>> > Yet another atomic_t -> refcount_t conversion, split in two patches.
>> > 
>> > First patch prepares the automatic conversion done in the second patch.
>> > 
>> > Eric Dumazet (2):
>> >   net: prepare (struct ubuf_info)->refcnt conversion
>> >   net: convert (struct ubuf_info)->refcnt to refcount_t
>> > 
>> >  drivers/vhost/net.c    |  2 +-
>> >  include/linux/skbuff.h |  5 +++--
>> >  net/core/skbuff.c      | 14 ++++----------
>> >  net/ipv4/tcp.c         |  2 --
>> >  4 files changed, 8 insertions(+), 15 deletions(-)
>> > 
>> 
>> David please ignore this series, I will send a V3 :)
>> 
> 
> No need for a V3, sorry for the confusion, but we had to double check
> with Willem that everything had been covered.
> 
> Please tell me if I need to resend, thanks !

Ok, series applied, thanks Eric.
