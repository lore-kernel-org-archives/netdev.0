From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 05/14] net: tcp_memcontrol: protect all tcp_memcontrol
 calls by jump-label
Date: Fri, 13 Nov 2015 11:01:22 -0500 (EST)
Message-ID: <20151113.110122.2158673468450208508.davem@davemloft.net>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mhocko-AlSwsSmVLrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org
To: hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1447371693-25143-6-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Date: Thu, 12 Nov 2015 18:41:24 -0500

> Move the jump-label from sock_update_memcg() and sock_release_memcg()
> to the callsite, and so eliminate those function calls when socket
> accounting is not enabled.
> 
> This also eliminates the need for dummy functions because the calls
> will be optimized away if the Kconfig options are not enabled.
> 
> Signed-off-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
