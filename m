From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/23] [PATCH] [XFRM] POLICY: Support netlink socket
 interface for sub policy.
Date: Tue, 01 Aug 2006 17:24:03 -0700 (PDT)
Message-ID: <20060801.172403.64001463.davem@davemloft.net>
References: <1154165455769-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28909
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750854AbWHBAYF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:24:05 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <1154165455769-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:55 +0900

> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> index 901bb65..68d3443 100644
> --- a/include/linux/xfrm.h
> +++ b/include/linux/xfrm.h
> @@ -303,12 +303,14 @@ #define XFRM_POLICY_BLOCK	1
>  	__u8				flags;
>  #define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */
>  	__u8				share;
> +	__u8				type;
>  };
>  
>  struct xfrm_userpolicy_id {
>  	struct xfrm_selector		sel;
>  	__u32				index;
>  	__u8				dir;
> +	__u8				type;
>  };
>  
>  struct xfrm_user_acquire {

Again, these are user visible data structures which cannot be
modified without changing the API.  Please use another xfrm
netlink attribute or similar to pass this information.
