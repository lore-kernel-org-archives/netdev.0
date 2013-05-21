From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next
 tree
Date: Tue, 21 May 2013 13:04:38 -0700
Message-ID: <20130521130438.1ecdf535ab2461888abbe0c3@linux-foundation.org>
References: <20130521142948.444f09820c5406f9adc4b7f1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Nicolas Schichan <nschichan@freebox.fr>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130521142948.444f09820c5406f9adc4b7f1@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 May 2013 14:29:48 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> Today's linux-next merge of the akpm tree got a conflict in
> arch/arm/net/bpf_jit_32.c between commit aafc787e41fd ("arm: bpf_jit: can
> call module_free() from any context") from the net-next tree and commit
> "bpf: add comments explaining the schedule_work() operation" from the
> akpm tree.
> 
> The former means that the latter is no longer required, so I used the
> former and can carry the fix as necessary (no action is required).

Yes, there have been a lot of conflicts in

seccomp-add-generic-code-for-jitted-seccomp-filters.patch
arm-net-bpf_jit-make-code-generation-less-dependent-on-struct-sk_filter.patch
arm-net-bpf_jit-make-code-generation-less-dependent-on-struct-sk_filter-fixup-merge-conflict.patch
arm-net-bpf_jit-add-support-for-jitted-seccomp-filters.patch

recently and I'm presently seeing a compilation error.

Nicolas, I think the patches need a re-check so I'll drop the versions
which I presently have.  Please refresh, retest and resend when
convenient?  It'll need to be against linux-next, which is where the
conflicting (vfree/module_free) changes have occurred.
