From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Fix the return value of ipv6_getsockopt
Date: Sun, 16 Dec 2007 13:40:15 -0800 (PST)
Message-ID: <20071216.134015.232602731.davem@davemloft.net>
References: <4760C6A0.4000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50307
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760140AbXLPVkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:40:25 -0500
In-Reply-To: <4760C6A0.4000300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 13 Dec 2007 14:44:00 +0900

> If CONFIG_NETFILTER if not selected when compile the kernel source code, 
> ipv6_getsockopt will returen an EINVAL error if optname is not supported by
> the kernel. But if CONFIG_NETFILTER is selected, ENOPROTOOPT error will 
> be return.
> This patch fix to always return ENOPROTOOPT error if optname argument of 
> ipv6_getsockopt is not supported by the kernel.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Patch applied to net-2.6, thanks for this bug fix.
