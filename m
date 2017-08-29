From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: increase queue_len_bytes to match
 wmem_default
Date: Tue, 29 Aug 2017 16:17:42 -0700 (PDT)
Message-ID: <20170829.161742.1076920872910435200.davem@davemloft.net>
References: <1504029689.11498.79.camel@edumazet-glaptop3.roam.corp.google.com>
        <1504044961.11498.100.camel@edumazet-glaptop3.roam.corp.google.com>
        <1504048528.11498.109.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdH2XRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:17:43 -0400
In-Reply-To: <1504048528.11498.109.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Aug 2017 16:15:28 -0700

> On Tue, 2017-08-29 at 15:16 -0700, Eric Dumazet wrote:
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index
>> 568ccfd6dd371d88136ffabe5cfcc36f099786b6..7616cd76f6f6a62f395da897baef2c66c0098193 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -6086,9 +6086,9 @@ int tcp_conn_request(struct request_sock_ops
>> *rsk_ops,
>>         struct tcp_sock *tp = tcp_sk(sk);
>>         struct net *net = sock_net(sk);
>>         struct sock *fastopen_sk = NULL;
>> -       struct dst_entry *dst = NULL;
>>         struct request_sock *req;
>>         bool want_cookie = false;
>> +       struct dst_entry *dst;
>>         struct flowi fl;
>>  
>>         /* TW buckets are converted to open req
> 
> This part was meant to belong to a separate patch :/
> 
> No big deal, this was also one of your suggestion David.

Yeah, no big deal.  But thanks for pointing it out.
