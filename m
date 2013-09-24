From: Geoff Levand <geoff@infradead.org>
Subject: Re: [PATCH 08/10] toshiba: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:26:44 -0700
Message-ID: <1380058004.9509.1.camel@smoke>
References: <cover.1380056108.git.joe@perches.com>
	 <3e0dd1f4722f8e0c10a47b9bbb26e891e79fef60.1380056108.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>, cbe-oss-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3e0dd1f4722f8e0c10a47b9bbb26e891e79fef60.1380056108.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-09-24 at 14:10 -0700, Joe Perches wrote:
> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
> 
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/toshiba/ps3_gelic_net.h      | 29 +++++++++++------------
>  drivers/net/ethernet/toshiba/ps3_gelic_wireless.h |  6 ++---
>  drivers/net/ethernet/toshiba/spider_net.h         |  4 ++--
>  3 files changed, 19 insertions(+), 20 deletions(-)

Looks good.  Thanks.

Acked-by: Geoff Levand <geoff@infradead.org>
