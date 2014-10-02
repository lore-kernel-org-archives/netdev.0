From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bpf: add search pruning optimization and
 tests
Date: Wed, 01 Oct 2014 21:31:10 -0400 (EDT)
Message-ID: <20141001.213110.1976557946620505084.davem@davemloft.net>
References: <1412041802-24858-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, torvalds@linux-foundation.org,
	luto@amacapital.net, dborkman@redhat.com,
	hannes@stressinduktion.org, chema@google.com, edumazet@google.com,
	a.p.zijlstra@chello.nl, pablo@netfilter.org, hpa@zytor.com,
	akpm@linux-foundation.org, keescook@chromium.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412041802-24858-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 29 Sep 2014 18:50:00 -0700

> patch #1 commit log explains why eBPF verifier has to examine some
> instructions multiple times and describes the search pruning optimization
> that improves verification speed for branchy programs and allows more
> complex programs to be verified successfully.
> This patch completes the core verifier logic.
> 
> patch #2 adds more verifier tests related to branches and search pruning
> 
> I'm still working on Andy's 'bitmask for stack slots' suggestion. It will be
> done on top of this patch.
> 
> The current verifier algorithm is brute force depth first search with
> state pruning. If anyone can come up with another algorithm that demonstrates
> better results, we'll replace the algorithm without affecting user space.
> 
> Note verifier doesn't guarantee that all possible valid programs are accepted.
> Overly complex programs may still be rejected.
> Verifier improvements/optimizations will guarantee that if a program
> was passing verification in the past, it will still be passing.

Series applied, thanks.
