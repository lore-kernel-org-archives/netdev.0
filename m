From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bpf: grab rcu read lock for bpf_percpu_hash_update
Date: Fri, 19 Feb 2016 14:41:47 -0500 (EST)
Message-ID: <20160219.144147.2294845693331071229.davem@davemloft.net>
References: <1455907990-22250-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455907990-22250-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Fri, 19 Feb 2016 13:53:10 -0500

> bpf_percpu_hash_update() expects rcu lock to be held and warns if it's not,
> which pointed out a missing rcu read lock.
> 
> Fixes: 15a07b338 ("bpf: add lookup/update support for per-cpu hash and array maps")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
