From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: Include linux/if_ether.h to fix build error
Date: Thu, 01 Dec 2011 12:41:19 -0500 (EST)
Message-ID: <20111201.124119.485939880534098580.davem@davemloft.net>
References: <1322726838.14554.3.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322726838.14554.3.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>
Date: Thu, 01 Dec 2011 16:07:18 +0800

> Include linux/if_ether.h to fix below build errors:
> 
>   CC      arch/arm/mach-kirkwood/common.o
> In file included from arch/arm/mach-kirkwood/common.c:19:
> include/net/dsa.h: In function 'dsa_uses_dsa_tags':
> include/net/dsa.h:192: error: 'ETH_P_DSA' undeclared (first use in this function)
> include/net/dsa.h:192: error: (Each undeclared identifier is reported only once
> include/net/dsa.h:192: error: for each function it appears in.)
> include/net/dsa.h: In function 'dsa_uses_trailer_tags':
> include/net/dsa.h:197: error: 'ETH_P_TRAILER' undeclared (first use in this function)
> make[1]: *** [arch/arm/mach-kirkwood/common.o] Error 1
> make: *** [arch/arm/mach-kirkwood] Error 2
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Applied.
