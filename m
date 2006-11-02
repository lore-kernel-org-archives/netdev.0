From: walter harms <wharms@bfs.de>
Subject: Re: [KJ] [tipc-discussion] [patch] net/tipc: sprintf/strcpy	conversion
Date: Thu, 02 Nov 2006 08:57:55 +0100
Message-ID: <4549A503.5040005@bfs.de>
References: <20061101140624.GA7694@Chamillionaire.breakpoint.cc>	<454913D2.9050608@bfs.de> <20061102062656.GA8339@Chamillionaire.breakpoint.cc>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.fr.bfs.de ([194.95.226.137]:40936 "EHLO mail.fr.bfs.de")
	by vger.kernel.org with ESMTP id S1752720AbWKBH57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 02:57:59 -0500
To: tipc-discussion@lists.sourceforge.net,
	kernel-janitors@lists.osdl.org, netdev@vger.kernel.org
In-Reply-To: <20061102062656.GA8339@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Florian Westphal wrote:
> walter harms <wharms@bfs.de> wrote:
>> These line
>> +       strcpy(bcbearer->media.name, "tipc-multicast");
>> i gues that means tipc_bclink_name ?
> 
> The idea was to change how things are done, not _what_ is being done.
> 
>> an even more secure version could be like this:
>>
>> 	strncpy(bcbearer->media.name,sizeof(bcbearer->media.name),tipc_bclink_name);
> 
> Ugh, please, no. The size of src is known in all cases; there is
> absoluty no point in using str(n|l)cpy here.
> 
>> (in case someone ever changes the size of cbearer->media.name or tipc_bclink_name and the hope
>> that wchat_t will never reach the kernel)
> 
> In this case 'someone' should be really hurt, don't you think?
> 

hi florian,
i am on the side of error, the code increase is marginal and the speed penalty also, so why not ?
you make sure that an overflow may never happen, and the rest in name gets zeroed.

The problem is that when the error occurs it may be later than the actual changeset.
NTL it is an hint, and if you feel ok with it and the maintainer has no objects i have no problems either.

re,
 wh


