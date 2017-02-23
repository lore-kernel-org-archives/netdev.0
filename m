From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi: fix linux/ip6_tunnel.h userspace compilation
 errors
Date: Thu, 23 Feb 2017 10:47:08 -0500 (EST)
Message-ID: <20170223.104708.389386681922163973.davem@davemloft.net>
References: <20170222223803.GA14311@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170222223803.GA14311@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 23 Feb 2017 01:38:03 +0300

> Include <linux/if.h> and <linux/in6.h> to fix the following
> linux/ip6_tunnel.h userspace compilation errors:
> 
> /usr/include/linux/ip6_tunnel.h:23:12: error: 'IFNAMSIZ' undeclared here (not in a function)
>   char name[IFNAMSIZ]; /* name of tunnel device */
> /usr/include/linux/ip6_tunnel.h:30:18: error: field 'laddr' has incomplete type
>   struct in6_addr laddr; /* local tunnel end-point address */
> 
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Applied.
