From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] uapi: fix linux/ipv6_route.h userspace compilation
 errors
Date: Sun, 19 Feb 2017 18:15:39 -0500 (EST)
Message-ID: <20170219.181539.544561989233958078.davem@davemloft.net>
References: <20170215200546.GE1028@altlinux.org>
        <20170216150414.GA13804@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216150414.GA13804@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 16 Feb 2017 18:04:14 +0300

> Include <linux/in6.h> to fix the following linux/ipv6_route.h userspace
> compilation errors:
> 
> /usr/include/linux/ipv6_route.h:42:19: error: field 'rtmsg_dst' has incomplete type
>   struct in6_addr  rtmsg_dst;
> /usr/include/linux/ipv6_route.h:43:19: error: field 'rtmsg_src' has incomplete type
>   struct in6_addr  rtmsg_src;
> /ust/include/linux/ipv6_route.h:44:19: error: field 'rtmsg_gateway' has incomplete type
>   struct in6_addr  rtmsg_gateway;
> 
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Applied.
