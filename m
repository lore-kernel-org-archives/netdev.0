From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Annotate change of locking mechanism for np->opt
Date: Thu, 18 Feb 2016 15:27:42 -0500 (EST)
Message-ID: <20160218.152742.1155043167293398507.davem@davemloft.net>
References: <1455754833-31567-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com
To: bpoirier@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455754833-31567-1-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.com>
Date: Wed, 17 Feb 2016 16:20:33 -0800

> follows up commit 45f6fad84cc3 ("ipv6: add complete rcu protection around
> np->opt") which added mixed rcu/refcount protection to np->opt.
> 
> Given the current implementation of rcu_pointer_handoff(), this has no
> effect at runtime.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Since it has no effect on run-time, applied to net-next, thanks.
