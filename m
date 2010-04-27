From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 13:02:08 -0400
Message-ID: <4BD71890.2050606@athenacr.com>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>	<20100426.110432.104061817.davem@davemloft.net>	<4BD6E887.3000804@athenacr.com> <20100427.095108.68126984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:2967 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751093Ab0D0RCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:02:10 -0400
In-Reply-To: <20100427.095108.68126984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brian Bloniarz <bmb@athenacr.com>
> Date: Tue, 27 Apr 2010 09:37:11 -0400
> 
>> David Miller wrote:
>>> How damn hard is it to add two 16-bit ports to the hash regardless of
>>> protocol?
>>>   
>> Come to think of it, for UDP the hash must ignore
>> the srcport and srcaddr, because a single bound
>> socket is going to wildcard both those fields.
> 
> For load distribution we don't care if the local socket is wildcard
> bounded on source.
> 
> It's going to be fully specified in the packet, and that's enough.

Maybe I'm misunderstanding... won't it distribute the
packet handling load to multiple cores, but then all
those cores will contend trying to deliver those packets
to the single socket?

I was assuming that this'd be a net loss over just doing
all the protocol handling on a single core. I haven't
done any benchmarks yet.
