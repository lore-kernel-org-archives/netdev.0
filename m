From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] timers: add mod_timer_pending()
Date: Wed, 18 Feb 2009 14:47:38 +0100
Message-ID: <20090218134738.GD1300@elte.hu>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <499BDDFE.5010101@trash.net> <20090218120508.GB4100@elte.hu> <499C000A.4040205@trash.net> <20090218125049.GA28791@elte.hu> <499C0519.2050204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <499C0519.2050204@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Patrick McHardy <kaber@trash.net> wrote:

> Ingo Molnar wrote:
>> To accelerate matters i've committed the new API patch into a new 
>> standalone topic branch: tip:timers/new-apis.
>>
>> Unless there are objections or test failures, you (or Stephen or  
>> David) can then git-pull it into the networking tree via the Git  
>> coordinates below - and you'll get this single commit in a surgical 
>> manner - no other timer changes are included.
>>
>> Doing so has the advantage of:
>>
>> - You not having to wait a kernel cycle for the API to go
>>   upstream.
>>
>> - You can also push it upstream without waiting for the timer   tree. 
>> (the timer tree and the networking tree will share the   exact same 
>> commit)
>>
>> - It will also all merge cleanly with the timer tree in   linux-next, 
>> etc.
>>
>> I'd suggest to do it in about a week, to make sure any after effects 
>> have trickled down and to make sure the topic has become append-only. 
>> You can ping Thomas and me about testing/review status then, whenever 
>> you want to do the pull.
>
> Thanks Ingo. I'll wait for Stephen to rebase his patches on 
> top of your change and the test results and will let you know.

Stress-testing here in the last ~2 hours on eight x86 test-boxes 
showed no problems so far.

	Ingo
