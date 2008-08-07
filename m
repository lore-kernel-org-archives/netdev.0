From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/route.c: fix build error
Date: Wed, 06 Aug 2008 18:31:04 -0700 (PDT)
Message-ID: <20080806.183104.55343544.davem@davemloft.net>
References: <489269AB.8050706@cn.fujitsu.com>
	<20080731.205132.203087940.davem@davemloft.net>
	<4899A173.2050807@teltonika.lt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, mingo@elte.hu, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org
To: paulius.zaleckas@teltonika.lt
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754482AbYHGBbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 21:31:04 -0400
In-Reply-To: <4899A173.2050807@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Date: Wed, 06 Aug 2008 16:04:51 +0300

> This function is over ifdef'ed :)
> 
> #ifdef CONFIG_SYSCTL
> /*
>   * We really need to sanitize the damn ipv4 init order, then all
>   * this nonsense will go away.
>   */
> void __init ip_static_sysctl_init(void)
> {
> #ifdef CONFIG_SYSCTL
> 	register_sysctl_paths(ipv4_route_path, ipv4_route_table);
> #endif
> }
> #endif

Thanks, I've gotten rid of the inner ones in my tree.
