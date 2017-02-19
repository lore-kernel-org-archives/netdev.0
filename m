From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] uapi: fix linux/mroute6.h userspace compilation
 errors
Date: Sun, 19 Feb 2017 18:15:48 -0500 (EST)
Message-ID: <20170219.181548.729360642029677847.davem@davemloft.net>
References: <20170215200617.GF1028@altlinux.org>
        <20170216150429.GB13804@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216150429.GB13804@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 16 Feb 2017 18:04:29 +0300

> Include <linux/in6.h> to fix the following linux/mroute6.h userspace
> compilation errors:
> 
> /usr/include/linux/mroute6.h:80:22: error: field 'mf6cc_origin' has incomplete type
>   struct sockaddr_in6 mf6cc_origin;  /* Origin of mcast */
> /usr/include/linux/mroute6.h:81:22: error: field 'mf6cc_mcastgrp' has incomplete type
>   struct sockaddr_in6 mf6cc_mcastgrp;  /* Group in question */
> /usr/include/linux/mroute6.h:91:22: error: field 'src' has incomplete type
>   struct sockaddr_in6 src;
> /usr/include/linux/mroute6.h:92:22: error: field 'grp' has incomplete type
>   struct sockaddr_in6 grp;
> /usr/include/linux/mroute6.h:132:18: error: field 'im6_src' has incomplete type
>   struct in6_addr im6_src, im6_dst;
> /usr/include/linux/mroute6.h:132:27: error: field 'im6_dst' has incomplete type
>   struct in6_addr im6_src, im6_dst;
> 
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Applied.
