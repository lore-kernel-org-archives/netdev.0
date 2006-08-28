From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] ROUTE: Fix dst refcounting.
Date: Mon, 28 Aug 2006 13:19:58 -0700 (PDT)
Message-ID: <20060828.131958.94888288.davem@davemloft.net>
References: <20060829.014649.37985556.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, CHINEN@jp.ibm.com,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58576
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751461AbWH1UTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:19:55 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060829.014649.37985556.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 29 Aug 2006 01:46:49 +0900 (JST)

> [IPV6] ROUTE: Fix dst reference counting in ip6_pol_route_lookup().
> 
> In ip6_pol_route_lookup(), when we finish backtracking at the
> top-level root entry, we need to hold it.
> 
> Bug noticed by Mitsuru Chinen <CHINEN@jp.ibm.com>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you.
