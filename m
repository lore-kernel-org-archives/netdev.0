From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 07/36] net,
 rcu: convert call_rcu(ip_mc_list_reclaim) to kfree_rcu()
Date: Fri, 18 Mar 2011 12:35:53 -0700 (PDT)
Message-ID: <20110318.123553.183052249.davem@davemloft.net>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
	<4D82D508.5080901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	James.Bottomley-l3A5Bk7waGM@public.gmane.org, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org,
	mingo-X9Un+BFzKDI@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <4D82D508.5080901-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.open-fcoe.org/mailman/options/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date: Fri, 18 Mar 2011 11:44:08 +0800

> 
> 
> The rcu callback ip_mc_list_reclaim() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(ip_mc_list_reclaim).
> 
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
