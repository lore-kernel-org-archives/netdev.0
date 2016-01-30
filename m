From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Sat, 30 Jan 2016 09:51:53 -0800
Message-ID: <1454176313.7627.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
	 <1454159878-20706-3-git-send-email-tanure@linux.com>
	 <20160130134550.GA5613@macbook.localdomain>
	 <CAJX_Q+18D3omXJRy-2CEieqhAXCwpFwwt=JiRWkozPqs4cC96g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lucas Tanure <tanure@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJX_Q+18D3omXJRy-2CEieqhAXCwpFwwt=JiRWkozPqs4cC96g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-01-30 at 12:05 -0200, Lucas Tanure wrote:
> On Sat, Jan 30, 2016 at 11:45 AM, Patrick McHardy <kaber@trash.net> wrote:
> > On 30.01, Lucas Tanure wrote:
> >> As suggested by checkpatch.pl:
> >> CHECK: Prefer kernel type 'uX' over 'uintX_t'
> >
> > You might have noticed we have literally hundreds of them spread over 100
> > files in the netfilter code. We'll gradually change them when the code is
> > touched anyways.
> >
> >>  net/ipv4/netfilter/ip_tables.c | 5 ++---
> >>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> Yes, I checked that. But would be better to change that now?
> Because:
> - could take years to anyone to touch the code, as the code already
> works very well
> - be more standardized could facilitate reading the code
> - It's a good way to encourage new people to contribute to the code
> 
> Thanks!

These changes are a pain for people having to constantly backport fixes
into stable kernels, or rebase their patches before upstream
submissions.

Things like 'git cherry-pick' , 'git rebase' no longer work.
This is a huge pain, and manual editing to resolve conflicts often
add bugs.

Really, do you believe the 'uX' over 'uintX_t' stuff really matters for
people working on adding new features and fixing bugs ?

I am certain that if you had to work like us, you would quickly see the
utility of such changes is negative.

Sure, new submissions should be clean, but 'fixing' old code is not
worth it.
