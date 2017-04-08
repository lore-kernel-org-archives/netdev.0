From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/1 v2] skbuff: Extend gso_type to unsigned
 int.
Date: Sat, 08 Apr 2017 12:32:34 -0700 (PDT)
Message-ID: <20170408.123234.1062158742988397943.davem@davemloft.net>
References: <1491676584-22421-1-git-send-email-steffen.klassert@secunet.com>
        <1491676584-22421-2-git-send-email-steffen.klassert@secunet.com>
        <1491677732.10124.94.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
        edumazet@google.com, alexander.duyck@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdDHTck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 15:32:40 -0400
In-Reply-To: <1491677732.10124.94.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 08 Apr 2017 11:55:32 -0700

> On Sat, 2017-04-08 at 20:36 +0200, Steffen Klassert wrote:
>> All available gso_type flags are currently in use, so
>> extend gso_type from 'unsigned short' to 'unsigned int'
>> to be able to add further flags.
>> 
>> We reorder the struct skb_shared_info to use
>> two bytes of the four byte hole before dataref.
>> All fields before dataref are cleared, i.e.
>> four bytes more than before the change.
>> 
>> The remaining two byte hole is moved to the
>> beginning of the structure, this protects us
>> from immediate overwites on out of bound writes
>> to the sk_buff head.
> 
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
...
> This looks much better, thanks Steffen.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
