From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC PATCH net-next 0/6] seccomp filter JIT
Date: Fri, 26 Apr 2013 13:25:39 +0200
Message-ID: <20130426112539.GA3736@osiris>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 26, 2013 at 03:51:40AM -0400, Xi Wang wrote:
> This patchset brings JIT support to seccomp filters for x86_64 and ARM.
> It is against the net-next tree.
> 
> The current BPF JIT interface only accepts sk_filter, not seccomp_filter.
> Patch 1/6 refactors the interface to make it more general.
> 
> With the refactored interface, patches 2/6 and 3/6 implement the seccomp
> BPF_S_ANC_SECCOMP_LD_W instruction in x86 & ARM JIT.
> 
> Status:
> 
> * x86_64 & ARM: JIT tested with seccomp examples.
> 
> * powerpc [4/6]: no seccomp change - compile checked.
> 
> * sparc [5/6] & s390 [6/6]: no seccomp change - untested.
> 
> Sorry I have no sparc or s390 build environment here.  Can someone help
> check 5/6 and 6/6?  Thanks.

Your patches are against which tree?
They don't apply on top of linux-next or Linus' linux tree.

Btw. are there any test cases around for BPF JIT?
Not only for the new seccomp but also netfilter?
