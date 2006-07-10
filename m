From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: order addresses by scope
Date: Mon, 10 Jul 2006 15:00:45 -0700 (PDT)
Message-ID: <20060710.150045.128593827.davem@davemloft.net>
References: <4489BA9A.9050508@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37788
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965041AbWGJWAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:00:09 -0400
To: brian.haley@hp.com
In-Reply-To: <4489BA9A.9050508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 09 Jun 2006 14:14:50 -0400

> If IPv6 addresses are ordered by scope, then ipv6_dev_get_saddr() can 
> break-out of the device addr_list for() loop when the candidate source 
> address scope is less than the destination address scope.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

This patch looks fine to me, it's an optimization and not a
correctness issue.

But I'd like an ACK from an ipv6 developer, such as Yoshifuji, before
adding this patch.

Thanks.
