From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: drop "select LLIST"
Date: Mon, 14 Nov 2011 00:12:10 -0500 (EST)
Message-ID: <20111114.001210.728555642579535986.davem@davemloft.net>
References: <1321191397.20271.62.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321191397.20271.62.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Sun, 13 Nov 2011 14:36:37 +0100

> Commit 1bc144b625 ("net, rds, Replace xlist in net/rds/xlist.h with
> llist") added "select LLIST" to the RDS_RDMA Kconfig entry. But there is
> no Kconfig symbol named LLIST. The select statement for that symbol is a
> nop. Drop it.
> 
> lib/llist.o is builtin, so all that's needed to use the llist
> functionality is to include linux/llist.h, which this commit also did.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied.
