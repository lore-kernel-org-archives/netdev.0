From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NETLINK: convert NLMSG_GOODSIZE to constant expression.
Date: Tue, 06 Mar 2007 23:36:50 -0800 (PST)
Message-ID: <20070306.233650.18580718.davem@davemloft.net>
References: <20070307.163401.110957772.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161133AbXCGHgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 02:36:52 -0500
In-Reply-To: <20070307.163401.110957772.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 07 Mar 2007 16:34:01 +0900 (JST)

> This fixes the following error:
> :
> |  CC [M]  net/ipv4/netfilter/ipt_ULOG.o
> |net/ipv4/netfilter/ipt_ULOG.c:82: error: braced-group within expression allowed only inside a function
> |net/ipv4/netfilter/ipt_ULOG.c:82: error: syntax error before "void"
> |make[1]: *** [net/ipv4/netfilter/ipt_ULOG.o] Error 1
> |make: *** [net/ipv4/netfilter/] Error 2
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Sorry about this :-/

Thanks for the fix, applied.
