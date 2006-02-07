From: Willy Tarreau <willy@w.ods.org>
Subject: Re: [Patch] 2.4.32 - Neighbour Cache (ARP) State machine bug Fixed
Date: Tue, 7 Feb 2006 22:53:42 +0100
Message-ID: <20060207215341.GC11380@w.ods.org>
References: <9fda5f510511281257o364acb3gd634f8e412cd7301@mail.gmail.com> <9fda5f510602031806j2f9ef743t206c9ee2c3bef384@mail.gmail.com> <20060203.181839.104353534.davem@davemloft.net> <9fda5f510602062357n38292cebk3c5738ccdbee83@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965160AbWBGVxw@vger.kernel.org>
To: Pradeep Vincent <pradeep.vincent@gmail.com>
Content-Disposition: inline
In-Reply-To: <9fda5f510602062357n38292cebk3c5738ccdbee83@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Feb 07, 2006 at 12:57:43AM -0700, Pradeep Vincent wrote:
> In 2.4.21, arp code uses gc_timer to check for stale arp cache
> entries. In 2.6, each entry has its own timer to check for stale arp
> cache. 2.4.29 to 2.4.32 kernels (atleast) use neither of these timers.
> This causes problems in environments where IPs or MACs are reassigned
> - saw this problem on load balancing router based networks that use
> VMACs. Tested this code on load balancing router based networks as
> well as peer-linux systems.
> 
> 
> Thanks,
> 
> 
> Signed off by: Pradeep Vincent <pradeep.vincent@gmail.com>
> 
> diff -Naur old/net/core/neighbour.c new/net/core/neighbour.c
> --- old/net/core/neighbour.c    Wed Nov 23 17:15:30 2005
> +++ new/net/core/neighbour.c    Wed Nov 23 17:26:01 2005
> @@ -14,6 +14,7 @@
> *     Vitaly E. Lavrov        releasing NULL neighbor in neigh_add.
> *     Harald Welte            Add neighbour cache statistics like rtstat
> *     Harald Welte            port neighbour cache rework from 2.6.9-rcX
> + *      Pradeep Vincent         Move neighbour cache entry to stale state
> */

As you can see above, your mailer is still broken. Leading spaces get
removed and it seems like tabs are replaced with spaces. This makes it
really annoying to fix by hand because we all have to do your work again.
You should try to fix your mailer options, possibly by sending a few
mails to yourself or someone else (if you send *a few* mails to me, I
can confirm which one looks OK). If your mailer is definitely broken,
then you may send it as plain text first (for review), with a text
attachment for people to apply it without trouble.

Thanks,
Willy
