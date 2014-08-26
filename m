From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 12/35] [PATCH 12/36] net: Replace get_cpu_var through
 this_cpu_ptr
Date: Tue, 26 Aug 2014 14:09:08 -0400
Message-ID: <20140826180908.GU31659@mtj.dyndns.org>
References: <20140817173023.439660246@linux.com>
 <20140817173034.793528138@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140817173034.793528138@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 17, 2014 at 12:30:35PM -0500, Christoph Lameter wrote:
> Replace uses of get_cpu_var for address calculation through this_cpu_ptr.
> 
> Cc: netdev@vger.kernel.org
> Cc: Eric Dumazet <edumazet@google.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Christoph Lameter <cl@linux.com>

(Please disregard the ones I posted for v1 of the patch series)

Applied to percpu/for-3.18-consistent-ops.  Please let me know if this
patch should be routed differently.  Note that this patch was to be
applied to percpu/for-3.17 but delayed due to build issues caused by
cpumask_var_t.

Thanks.

-- 
tejun
