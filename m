From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tcp: md5: check md5 signature without
 socket lock
Date: Wed, 06 Aug 2014 14:52:18 -0700 (PDT)
Message-ID: <20140806.145218.1742159418901363810.davem@davemloft.net>
References: <20140807014953.d8c4cde302bb9b30f8efe0e1@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807014953.d8c4cde302bb9b30f8efe0e1@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Thu, 7 Aug 2014 01:49:53 +0400

> Since a8afca032 (tcp: md5: protects md5sig_info with RCU) tcp_md5_do_lookup
> doesn't require socket lock, rcu_read_lock is enough. Therefore socket lock is
> no longer required for tcp_v{4,6}_inbound_md5_hash too, so we can move these
> calls (wrapped with rcu_read_{,un}lock) before bh_lock_sock:
> from tcp_v{4,6}_do_rcv to tcp_v{4,6}_rcv.
> 
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

Please respin this against the current 'net' tree, it doesn't apply.
