From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] netfilter: ctnetlink: remove incorrect
 spin_[un]lock_bh on NAT module autoload
Date: Tue, 06 Mar 2012 15:15:20 -0500 (EST)
Message-ID: <20120306.151520.1301826446269910707.davem@davemloft.net>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
	<1331032975-5303-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331032975-5303-3-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue,  6 Mar 2012 12:22:51 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Since 7d367e0, ctnetlink_new_conntrack is called without holding
> the nf_conntrack_lock spinlock. Thus, ctnetlink_parse_nat_setup
> does not require to release that spinlock anymore in the NAT module
> autoload case.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
