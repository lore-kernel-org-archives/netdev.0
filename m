From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP
 traffic
Date: Fri, 26 Jun 2009 13:02:50 -0700 (PDT)
Message-ID: <20090626.130250.209901333.davem@davemloft.net>
References: <bug-13627-10286@http.bugzilla.kernel.org/>
	<20090626124444.c24d9b38.akpm@linux-foundation.org>
	<20090626.130224.232645797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	olver@hartkopp.net, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750803AbZFZUCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:02:45 -0400
In-Reply-To: <20090626.130224.232645797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 26 Jun 2009 13:02:24 -0700 (PDT)

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, 26 Jun 2009 12:44:44 -0700
> 
>> It's a post-2.6.30 regression which Paul has bisected down to
>> 
>>   commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
>>   Author:     Herbert Xu <herbert@gondor.apana.org.au>
>>   AuthorDate: Mon Jun 22 02:25:25 2009 +0000
>>   Commit:     David S. Miller <davem@davemloft.net>
>>   CommitDate: Tue Jun 23 16:36:25 2009 -0700
>> 
>>       net: Move rx skb_orphan call to where needed
>> 
>> (thanks for doing the bisection!)
> 
> Then it's good that we partially reverted that change just
> the other day :-)

Ignore me, I'm an idiot...
