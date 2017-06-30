From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFC 12/26] arm64: Remove spin_unlock_wait() arch-specific
 definitions
Date: Fri, 30 Jun 2017 10:20:57 +0100
Message-ID: <20170630092057.GD9726@arm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-12-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, oleg@redhat.com, akpm@linux-foundation.org,
        mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com,
        tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org,
        peterz@infradead.org, stern@rowland.harvard.edu,
        parri.andrea@gmail.com, torvalds@linux-foundation.org,
        Catalin Marinas <catalin.marinas@arm.com>,
        linux-arm-kernel@lists.infradead.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498780894-8253-12-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 29, 2017 at 05:01:20PM -0700, Paul E. McKenney wrote:
> There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> and it appears that all callers could do just as well with a lock/unlock
> pair.  This commit therefore removes the underlying arch-specific
> arch_spin_unlock_wait().
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: <linux-arm-kernel@lists.infradead.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Andrea Parri <parri.andrea@gmail.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  arch/arm64/include/asm/spinlock.h | 58 ++++-----------------------------------
>  1 file changed, 5 insertions(+), 53 deletions(-)

I'm going to miss this code.

Acked-by: Will Deacon <will.deacon@arm.com>

Will
