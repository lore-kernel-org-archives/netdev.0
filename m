From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] IPV6: ICMP6_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 18:59:08 +0900 (JST)
Message-ID: <20080121.185908.29297942.yoshfuji@linux-ipv6.org>
References: <478DD57B.6020503@cn.fujitsu.com>
	<479469F8.4010203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dlstevens@us.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37661 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758454AbYAUJ6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 04:58:53 -0500
In-Reply-To: <479469F8.4010203@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <479469F8.4010203@cn.fujitsu.com> (at Mon, 21 Jan 2008 17:46:32 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> [IPV6]: ICMP6_MIB_OUTMSGS increment duplicated
> 
> icmpv6_send() calls ip6_push_pending_frames() indirectly.
> Both ip6_push_pending_frames() and icmpv6_send() increment
> counter ICMP6_MIB_OUTMSGS.
> 
> This patch remove the increment from icmpv6_send.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
