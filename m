From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] 2.6.14-rc5-mm1 net/ipv4/route.c: spin_unlock call fails to compile
Date: Fri, 28 Oct 2005 11:00:42 +0200
Message-ID: <20051028090042.GC14842@elte.hu>
References: <001401c5db8e$650bd380$1001a8c0@kalmiopsis>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965188AbVJ1JAV@vger.kernel.org>
To: John Bowler <jbowler@acm.org>
Content-Disposition: inline
In-Reply-To: <001401c5db8e$650bd380$1001a8c0@kalmiopsis>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* John Bowler <jbowler@acm.org> wrote:

>  #else
> -# define rt_hash_lock_addr(slot) NULL
> +# define rt_hash_lock_addr(slot) ((spinlock_t*)NULL)
>  # define rt_hash_lock_init()

looks good to me - it gives (slightly) more type safety too.

	Ingo
