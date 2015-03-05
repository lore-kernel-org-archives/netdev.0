From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Thu, 05 Mar 2015 00:01:58 -0500 (EST)
Message-ID: <20150305.000158.1662853297584626367.davem@davemloft.net>
References: <20150305134247.5a55e4db@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150305134247.5a55e4db@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 5 Mar 2015 13:42:47 +1100

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 5 Mar 2015 13:37:05 +1100
> Subject: [PATCH] mpls: using vzalloc requires including vmalloc.h
> 
> Fixes this build error:
> 
> net/mpls/af_mpls.c: In function 'resize_platform_label_table':
> net/mpls/af_mpls.c:767:4: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>     labels = vzalloc(size);
>     ^
> 
> Fixes: 7720c01f3f59 ("mpls: Add a sysctl to control the size of the mpls label table")
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks Stephen.
