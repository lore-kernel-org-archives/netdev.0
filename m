From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] Replace rcu_assign_pointer(x, NULL) with
 RCU_INIT_POINTER(x,NULL)
Date: Thu, 20 Mar 2014 17:04:58 -0400 (EDT)
Message-ID: <20140320.170458.1005538496220925120.davem@davemloft.net>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eddie.wai@broadcom.com, paulmck@linux.vnet.ibm.com
To: monamagarwal123@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Monam Agarwal <monamagarwal123@gmail.com>
Date: Thu, 20 Mar 2014 20:07:10 +0530

> This patchset uses following coccinelle script to replace
> rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)
> 
> @@
> expression E;
> @@
> - rcu_assign_pointer(
> + RCU_INIT_POINTER(
> E, NULL)

None of the networking patches apply to my net-next tree, in fact
nearly all of these case are already using RCU_INIT_POINTER()
properly.
