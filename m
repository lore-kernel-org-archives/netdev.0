From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPV6: ICMP6_MIB_OUTMSGS increment duplicated
Date: Mon, 21 Jan 2008 02:57:22 -0800 (PST)
Message-ID: <20080121.025722.147904573.davem@davemloft.net>
References: <478DD57B.6020503@cn.fujitsu.com>
	<479469F8.4010203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758336AbYAUK5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:57:16 -0500
In-Reply-To: <479469F8.4010203@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 21 Jan 2008 17:46:32 +0800

> [IPV6]: ICMP6_MIB_OUTMSGS increment duplicated
> 
> icmpv6_send() calls ip6_push_pending_frames() indirectly.
> Both ip6_push_pending_frames() and icmpv6_send() increment
> counter ICMP6_MIB_OUTMSGS.
> 
> This patch remove the increment from icmpv6_send.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Which tree are these two changes targetted at?
