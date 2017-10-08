From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/12] net/mlx5: replace <linux/radix-tree.h> with
 <linux/radix-tree-root.h>
Date: Sun, 08 Oct 2017 10:00:30 -0700 (PDT)
Message-ID: <20171008.100030.964611461320357569.davem@davemloft.net>
References: <1507479013-5207-1-git-send-email-yamada.masahiro@socionext.com>
        <1507479013-5207-12-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de,
        akpm@linux-foundation.org, abbotti@mev.co.uk, mingo@kernel.org,
        torvalds@linux-foundation.org, matanb@mellanox.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        saeedm@mellanox.com, leonro@mellanox.com
To: yamada.masahiro@socionext.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507479013-5207-12-git-send-email-yamada.masahiro@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Mon,  9 Oct 2017 01:10:12 +0900

> The header include/linux/mlx5/driver.h requires the definition of
> struct radix_tree_root, but does not need to know anything about
> other radix tree stuff.
> 
> Include <linux/radix-tree-root.h> instead of <linux/radix-tree.h> to
> reduce the number of included header files.
> 
> Also, add <linux/radix-tree.h> to include/linux/mlx5/gp.h where radix
> tree accessors are used.
> 
> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>

Same objections as the mlx4 changes, just include both headers in
driver.h
