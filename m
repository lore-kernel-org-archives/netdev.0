From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension
 headers sorting.
Date: Thu, 24 Aug 2006 04:58:50 -0700 (PDT)
Message-ID: <20060824.045850.74749237.davem@davemloft.net>
References: <20060824.150442.44820672.yoshfuji@linux-ipv6.org>
	<20060823.235404.108743952.davem@davemloft.net>
	<44ED4FC3.9060005@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17282
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751107AbWHXL6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 07:58:52 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44ED4FC3.9060005@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Thu, 24 Aug 2006 16:05:39 +0900

> David Miller wrote:
> > In the mean time, I will work on porting my XFRM hashing changes
> > for the current net-2.6.19 tree.
> 
> FYI, your work will not have any conflict with the left of MIPv6 patches
> which I will describe later since they are almost out of XFRM.

Great.

I just finished the port and pushed all of that work to net-2.6.19,
can folks please take a look?

I tested IPSEC as best as I could with XFRM_SUB_POLICY enabled, but I
have no way currently to test sub-policies or MIPV6 cases.

Thank you.
