From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Wrong list_lock argument in rose_node seqops
Date: Fri, 02 May 2008 17:03:34 -0700 (PDT)
Message-ID: <20080502.170334.97648357.davem@davemloft.net>
References: <200804302208.56925.bpidoux@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
To: bpidoux@free.fr
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <200804302208.56925.bpidoux@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard Pidoux <bpidoux@free.fr>
Date: Wed, 30 Apr 2008 22:08:56 +0200

> In rose_node_start() as well as in rose_node_stop()
> __acquires() and spin_lock_bh() were wrongly passing
> rose_neigh_list_lock instead of rose_node_list_lock arguments.
> 
> Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>

Applied, good catch.

Thanks Bernard.
