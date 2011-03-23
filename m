From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] drivers/net/ariadne.c: Convert release_resource to
 release_region/release_mem_region
Date: Wed, 23 Mar 2011 14:10:48 -0700 (PDT)
Message-ID: <20110323.141048.68130582.davem@davemloft.net>
References: <1300814123-25314-1-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, eric.dumazet@gmail.com,
	tj@kernel.org, crindy646@gmail.com, geert@linux-m68k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300814123-25314-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Tue, 22 Mar 2011 18:15:21 +0100

> Request_mem_region should be used with release_mem_region, not
> release_resource.
> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
