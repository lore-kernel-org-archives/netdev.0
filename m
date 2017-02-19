From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] uapi: fix linux/mroute.h userspace compilation
 errors
Date: Sun, 19 Feb 2017 18:16:17 -0500 (EST)
Message-ID: <20170219.181617.818841385499874965.davem@davemloft.net>
References: <20170215200650.GG1028@altlinux.org>
        <20170216150446.GC13804@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216150446.GC13804@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 16 Feb 2017 18:04:46 +0300

> Include <linux/in.h> to fix the following linux/mroute.h userspace
> compilation errors:
> 
> /usr/include/linux/mroute.h:58:18: error: field 'vifc_lcl_addr' has incomplete type
>   struct in_addr vifc_lcl_addr;     /* Local interface address */
> /usr/include/linux/mroute.h:61:17: error: field 'vifc_rmt_addr' has incomplete type
>   struct in_addr vifc_rmt_addr; /* IPIP tunnel addr */
> /usr/include/linux/mroute.h:72:17: error: field 'mfcc_origin' has incomplete type
>   struct in_addr mfcc_origin;  /* Origin of mcast */
> /usr/include/linux/mroute.h:73:17: error: field 'mfcc_mcastgrp' has incomplete type
>   struct in_addr mfcc_mcastgrp;  /* Group in question */
> /usr/include/linux/mroute.h:84:17: error: field 'src' has incomplete type
>   struct in_addr src;
> /usr/include/linux/mroute.h:85:17: error: field 'grp' has incomplete type
>   struct in_addr grp;
> /usr/include/linux/mroute.h:109:17: error: field 'im_src' has incomplete type
>   struct in_addr im_src,im_dst;
> /usr/include/linux/mroute.h:109:24: error: field 'im_dst' has incomplete type
>   struct in_addr im_src,im_dst;
> 
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Applied.
