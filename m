From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skfp: hwmtm: Use proper logging macros, correct
 mismatches
Date: Tue, 27 Dec 2016 20:17:06 -0500 (EST)
Message-ID: <20161227.201706.1509861992180599997.davem@davemloft.net>
References: <8e5313732124084fd2084df874eed70f8f1af810.1482367105.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8e5313732124084fd2084df874eed70f8f1af810.1482367105.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 21 Dec 2016 16:41:52 -0800

> Logging macros should allow format and argument validation.
> The DB_TX, DB_RX, and DB_GEN macros did not.
> 
> Update the macros and uses and add no_printk validation to the
> previously compiled away #ifndef DEBUG variants.
> 
> Done with coccinelle and some typing.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
