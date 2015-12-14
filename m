From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net, cgroup: cgroup_sk_updat_lock was missing
 initializer
Date: Mon, 14 Dec 2015 14:20:43 -0500 (EST)
Message-ID: <20151214.142043.1185024338854399910.davem@davemloft.net>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
	<f90d369a0e004fee8d3bfdfe95e0abc0@HKXPR3004MB0088.064d.mgd.msft.net>
	<20151214162406.GA4026@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: decui@microsoft.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com,
	lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151214162406.GA4026@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Mon, 14 Dec 2015 11:24:06 -0500

> bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup") added global
> spinlock cgroup_sk_update_lock but erroneously skipped initializer
> leading to uninitialized spinlock warning.  Fix it by using
> DEFINE_SPINLOCK().
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Dexuan Cui <decui@microsoft.com>
> Fixes: bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup")

Applied, thanks.
