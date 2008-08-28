From: Hans de Goede <j.w.r.degoede@hhs.nl>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 10:12:13 +0200
Message-ID: <48B65DDD.6020309@hhs.nl>
References: <20080827.164535.150037784.davem@davemloft.net>	<48B5F3E2.2000909@cosmosbay.com>	<20080828074536.GK26610@one.firstfloor.org> <20080828.005909.215643947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, dada1@cosmosbay.com, davej@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.versatel.nl ([62.58.50.88]:53103 "EHLO smtp1.versatel.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753693AbYH1IBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 04:01:01 -0400
In-Reply-To: <20080828.005909.215643947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Thu, 28 Aug 2008 09:45:36 +0200
> 
>>> When scanning route cache hash table, we can avoid taking locks for empty 
>>> buckets.
>> I'm not sure it's worth it in this case.  A rcu_read_lock() is a nop
>> (on non preemptible kernel) to very cheap (non atomic increment/decrement in 
>> cached task_struct) 
> 
> It's not one, it's at least two such increments, plus function calls,
> state checks, etc. since this is rcu_read_lock_bh().
> 

I'm very happy to see some progress on this and this leading to even more 
optimalizations elsewhere,

Thanks guys!

Regards,

Hans


p.s.

Can I please be removed from the CC, thanks!
