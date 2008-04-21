From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on
	latest -git
Date: Mon, 21 Apr 2008 15:39:53 +0200
Message-ID: <20080421133953.GJ9554@elte.hu>
References: <20080419100034.GA9475@elte.hu> <20080419.030337.244502148.davem@davemloft.net> <20080419103942.GA13599@elte.hu> <480C4CE8.6020202@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	kaber@trash.net, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:45965 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759161AbYDUNkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 09:40:14 -0400
Content-Disposition: inline
In-Reply-To: <480C4CE8.6020202@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jeff Garzik <jeff@garzik.org> wrote:

>> But in this case i first did an unsuccessful full-text search on 
>> lkml, then i also opened up netdev and did a full text search there 
>> too to find the originator pull request or the patches but the search 
>> turned up nothing. As the number of subsystems increases, i suspect 
>> you agree with me that this does not scale very well for bug 
>> reporters, correct?
>
> Well, 'git log [$file]' is even more scalable and precise, if 
> committer (as well as author) info and patch flow info is what a 
> tester or bug reporter seeks.

but the only information i had at that point was that 'something in that 
recent appearance of a large group of networking commits introduced the 
problem'. There was no commit log entry of even the merge.

> But it sounds like you are making an assumption about development 
> /style/, then complaining when reality doesn't match that assumption.

no. I simply failed to put this (trivial) bugreport into some sort of 
existing context of discussion, and made a brief and neutral(-looking) 
comment about that. Under no other development style could i have done 
that because the context was simply missing from the mailing lists.

I did not intend this to be a big deal comment. It was literally just 
this single side-question:

||  disabling CONFIG_NF_CONNTRACK_SIP works it around.
||
||  btw., i found no thread to reply to on lkml or elsewhere - arent all 
||  git pull requests supposed to be Cc:-ed to lkml, with shortlog 
||  included?

I was seriously surprised that large pull requests and shortlogs dont go 
to lkml. Perhaps some sort of negative sentiment was perceived in that 
single sentence of mine? If yes, how should i have expressed this 
comment otherwise?

and i mean, lost context of discussion happens all the time and i do it 
too - recently Andrew complained that ftrace commits were not on lkml 
and he was complaining rightfully. We dont notice it unless people 
mention it.

[ later on the tone of the discussion degenerated indeed. ]

	Ingo
