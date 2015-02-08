From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: Remove repeated function names from debug
 output
Date: Sat, 07 Feb 2015 22:42:14 -0800 (PST)
Message-ID: <20150207.224214.1963525404221310063.davem@davemloft.net>
References: <1423174641-11057-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423174641-11057-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Thu,  5 Feb 2015 23:17:20 +0100

> The macro rdsdebug is defined as
> 
>   pr_debug("%s(): " fmt, __func__ , ##args)
> 
> Hence it doesn't make sense to include the name of the calling
> function explicitly in the format string passed to rdsdebug.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied.
