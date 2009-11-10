From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH resent] Documentation: rw_lock lessons learned
Date: Tue, 10 Nov 2009 13:22:43 -0800
Message-ID: <20091110212243.GW8424@linux.vnet.ibm.com>
References: <4AF9C540.5090403@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758224AbZKJVW3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4AF9C540.5090403@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2009 at 02:55:44PM -0500, William Allen Simpson wrote:
> In recent weeks, two different network projects erroneously
> strayed down the rw_lock path.  Update the Documentation
> based upon comments in those threads.
>
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>   Documentation/spinlocks.txt |   14 ++++++++++++++
>   1 files changed, 14 insertions(+), 0 deletions(-)
>

> diff --git a/Documentation/spinlocks.txt b/Documentation/spinlocks.txt
> index 619699d..c112052 100644
> --- a/Documentation/spinlocks.txt
> +++ b/Documentation/spinlocks.txt
> @@ -233,4 +233,18 @@ indeed), while write-locks need to protect themselves against interrupts.
> 
>  		Linus

As you might guess, works for me!!!

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> +----
> +
> +The implications of spin_locks on memory are further described in:
> +
> +  Documentation/memory-barriers.txt
> +    (5) LOCK operations.
> +    (6) UNLOCK operations.
> +
> +----
> +
> +We are working hard to remove reader-writer spinlocks (rw_lock) from the
> +network stack, so please don't add a new one.  Instead, see:
> +
> +  Documentation/RCU/rcu.txt
> 
> -- 
> 1.6.3.3
> 
> 
