From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v2 4/4] kthread: use kthread_create_on_cpu()
Date: Tue, 30 Nov 2010 09:38:12 +0000
Message-ID: <15903.1291109892@redhat.com>
References: <1291043719.3435.981.camel@edumazet-laptop> <1290972833.29196.90.camel@edumazet-laptop> <20101128224024.GA12300@basil.fritz.box> <1290984712.29196.100.camel@edumazet-laptop> <20101128230146.GB12300@basil.fritz.box> <1290987424.29196.128.camel@edumazet-laptop> <20101129090510.GA15763@basil.fritz.box> <1291023532.3435.29.camel@edumazet-laptop>
Cc: dhowells@redhat.com, Andi Kleen <andi@firstfloor.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-arch@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291043719.3435.981.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:

> +		p = kthread_create_on_cpu(run_ksoftirqd, hcpu, hotcpu,
> +					  "ksoftirqd/%d", hotcpu);

Does kthread_create_on_cpu() need to take hotcpu twice?  Can one of the
arguments be folded into the other?

David
