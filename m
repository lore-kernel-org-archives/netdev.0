From: Lucas Tanure <tanure@linux.com>
Subject: Re: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Sat, 30 Jan 2016 16:41:50 -0200
Message-ID: <CAJX_Q+0ZOq5h0yu_E4ddQgMm4sfaijuM72A-1VOqCiBAKxCiOg@mail.gmail.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
	<1454159878-20706-3-git-send-email-tanure@linux.com>
	<20160130134550.GA5613@macbook.localdomain>
	<CAJX_Q+18D3omXJRy-2CEieqhAXCwpFwwt=JiRWkozPqs4cC96g@mail.gmail.com>
	<1454176313.7627.129.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454178361.7329.40.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454178361.7329.40.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 30, 2016 at 4:26 PM, Joe Perches <joe@perches.com> wrote:
> On Sat, 2016-01-30 at 09:51 -0800, Eric Dumazet wrote:
>> On Sat, 2016-01-30 at 12:05 -0200, Lucas Tanure wrote:
>> > On Sat, Jan 30, 2016 at 11:45 AM, Patrick McHardy <kaber@trash.net> wrote:
>> > > On 30.01, Lucas Tanure wrote:
>> > > > As suggested by checkpatch.pl:
>> > > > CHECK: Prefer kernel type 'uX' over 'uintX_t'
>> > >
>> > > You might have noticed we have literally hundreds of them spread over 100
>> > > files in the netfilter code. We'll gradually change them when the code is
>> > > touched anyways.
>> > >
>> > > >  net/ipv4/netfilter/ip_tables.c | 5 ++---
>> > > >  1 file changed, 2 insertions(+), 3 deletions(-)
>> >
>> > Yes, I checked that. But would be better to change that now?
>> > Because:
>> > - could take years to anyone to touch the code, as the code already
>> > works very well
>> > - be more standardized could facilitate reading the code
>> > - It's a good way to encourage new people to contribute to the code
>> >
>> > Thanks!
>>
>> These changes are a pain for people having to constantly backport fixes
>> into stable kernels, or rebase their patches before upstream
>> submissions.
>>
>> Things like 'git cherry-pick' , 'git rebase' no longer work.
>> This is a huge pain, and manual editing to resolve conflicts often
>> add bugs.
>>
>> Really, do you believe the 'uX' over 'uintX_t' stuff really matters for
>> people working on adding new features and fixing bugs ?
>>
>> I am certain that if you had to work like us, you would quickly see the
>> utility of such changes is negative.
>>
>> Sure, new submissions should be clean, but 'fixing' old code is not
>> worth it.
>
> That might depend on whether or not the linux kernel is
> a "long-life project" and whether or no any old branch
> of it is also important and sufficiently long-life.
>
> The active life of a backport branch for the linux kernel
> seems to be 3 or 4 years.  The linux kernel will likely
> be useful for a few more decades beyond that.
>
> Complex and long-life projects like the linux kernel
> might benefit more in code complexity reduction patches
> like these rather than code stasis for backward porting
> ease.
>
> In general, arguing for stasis leads to ossification,
> slow decline.
>
> Change for change's sake is poor, but changes to reduce
> complexity, improve maintainability (for some measure of
> it) and especially improve performance should be
> welcomed where feasible.
>

My goal was to improve maintainability for the code, and with time,
contribute with meaningful code.
As you might have noticed I didn't fix every checkpatch.pl warning and error.
I just sent the ones that I thought would improve the maintainability.

And backport fixes will always be a pain, no matter what.

Thanks for all the comments.
Sorry for anything.
