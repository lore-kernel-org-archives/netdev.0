From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC: 2.6 patch] net/netlink/: possible cleanups
Date: Thu, 13 Apr 2006 13:26:03 -0700 (PDT)
Message-ID: <20060413.132603.94193712.davem@davemloft.net>
References: <20060413162710.GE4162@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30386
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964966AbWDMU0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 16:26:18 -0400
To: bunk@stusta.de
In-Reply-To: <20060413162710.GE4162@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Thu, 13 Apr 2006 18:27:10 +0200

> This patch contains the following possible cleanups plus changes related 
> to them:
> - make the following needlessly global functions static:
>   - attr.c: __nla_reserve()
>   - attr.c: __nla_put()
> - #if 0 the following unused global functions:
>   - attr.c: nla_validate()
>   - attr.c: nla_find()
>   - attr.c: nla_memcpy()
>   - attr.c: nla_memcmp()
>   - attr.c: nla_strcmp()
>   - attr.c: nla_reserve()
>   - genetlink.c: genl_unregister_ops()
> - remove the following unused EXPORT_SYMBOL's:
>   - af_netlink.c: netlink_set_nonroot
>   - attr.c: nla_parse
>   - attr.c: nla_strlcpy
>   - attr.c: nla_put
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Bunk-bot, you have to stop.

These interfaces were added so that new users of netlink could
write their code more easily.

Unused does not equate to "comment out or delete".
