From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: correct memory barrier usage in
 tcp_check_space()
Date: Wed, 25 Jan 2017 13:23:49 -0500 (EST)
Message-ID: <20170125.132349.547836653319181331.davem@davemloft.net>
References: <1485312581-13041-1-git-send-email-jbaron@akamai.com>
        <1485320017.16328.386.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbaron@akamai.com, netdev@vger.kernel.org, oleg@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdAYSX4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:23:56 -0500
In-Reply-To: <1485320017.16328.386.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Jan 2017 20:53:37 -0800

> On Tue, 2017-01-24 at 21:49 -0500, Jason Baron wrote:
>> From: Jason Baron <jbaron@akamai.com>
>> 
>> sock_reset_flag() maps to __clear_bit() not the atomic version clear_bit().
>> Thus, we need smp_mb(), smp_mb__after_atomic() is not sufficient.
>> 
>> Fixes: 3c7151275c0c ("tcp: add memory barriers to write space paths")
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Oleg Nesterov <oleg@redhat.com>
>> Signed-off-by: Jason Baron <jbaron@akamai.com>
>> ---
>>  net/ipv4/tcp_input.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> I believe this would need also this for proper attribution.
> 
> Reported-by: Oleg Nesterov <oleg@redhat.com>

Applied, thanks everyone.
