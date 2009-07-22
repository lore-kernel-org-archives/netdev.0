From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 21 Jul 2009 20:18:55 -0700 (PDT)
Message-ID: <20090721.201855.32703627.davem@davemloft.net>
References: <1247588890.7500.186.camel@twins>
	<alpine.LFD.2.01.0907140940440.13838@localhost.localdomain>
	<1247832892.15751.35.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: peterz@infradead.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756313AbZGVDSv@vger.kernel.org>
In-Reply-To: <1247832892.15751.35.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 17 Jul 2009 14:14:52 +0200

> On Tue, 2009-07-14 at 09:42 -0700, Linus Torvalds wrote:
>> 
>> On Tue, 14 Jul 2009, Peter Zijlstra wrote:
>> > 
>> > Linus really hated the softirq mode, which is what prompted me to change
>> > that.
>> > 
>> > Now, it might be he only hated the particular interface and the
>> > resulting code, but I think to remember he simply thought the whole
>> > thing daft.
>> 
>> Yes. And I hated the bugs it had. 
>> 
>> Don't make something as core as timers any more complicated. Don't take 
>> locks in timers and then complain about deadlocks. If your locking is 
>> broken, don't make the core timers be idiotically broken.
>> 
>> Because it was. The code was a total mess to follow, and had bugs.
> 
> How would something like the below work for people?

I like it, but like Linus said it probably belongs in
kernel/softirq.c
