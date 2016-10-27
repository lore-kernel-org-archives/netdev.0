From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: core: Add a UID field to struct sock.
Date: Thu, 27 Oct 2016 16:02:11 -0400 (EDT)
Message-ID: <20161027.160211.1148220212159032382.davem@davemloft.net>
References: <1477588841-140767-1-git-send-email-lorenzo@google.com>
        <1477588841-140767-2-git-send-email-lorenzo@google.com>
        <1477589786.7065.220.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, netdev@vger.kernel.org, ek@google.com,
        zenczykowski@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33310 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932887AbcJ0UCT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:02:19 -0400
In-Reply-To: <1477589786.7065.220.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Oct 2016 10:36:26 -0700

> On Fri, 2016-10-28 at 02:20 +0900, Lorenzo Colitti wrote:
> 
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index d8e4532e..831e4e8 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -1570,6 +1570,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>>  		 */
>>  		sk_refcnt_debug_inc(newsk);
>>  		sk_set_socket(newsk, NULL);
>> +		newsk->sk_uid = sk->sk_uid;
> 
> Not sure why this is needed ?
> 
> sk_clone_lock() already copies sk to newsk, using sock_copy(newsk, sk);

Agreed.
