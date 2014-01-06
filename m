From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 6 Jan 2014 06:10:43 +0100
Message-ID: <20140106051043.GA3307@order.stressinduktion.org>
References: <20140106155413.914ed0922423400deaf87926@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Li RongQing <roy.qing.li@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140106155413.914ed0922423400deaf87926@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 06, 2014 at 03:54:13PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> In file included from net/core/dev.c:134:0:
> include/linux/if_macvlan.h: In function 'macvlan_count_rx':
> include/linux/if_macvlan.h:68:3: error: invalid use of undefined type 'struct vlan_pcpu_stats'
>    pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
>    ^
> 
> And lots more.
> 
> Caused by commit cdf3e274cf1b ("macvlan: unify macvlan_pcpu_stats and
> vlan_pcpu_stats");
> 
> I have reverted that commit for today.

This is fixed by:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1e85c9b66d86a776e78c332d5d32ae370ab84d3f

Greetings,

  Hannes
