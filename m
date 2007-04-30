From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] [XFRM]: Restrict upper layer information by
 bundle.
Date: Mon, 30 Apr 2007 00:34:37 -0700 (PDT)
Message-ID: <20070430.003437.57159715.davem@davemloft.net>
References: <11758443392651-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423120AbXD3Hek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:34:40 -0400
In-Reply-To: <11758443392651-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri,  6 Apr 2007 16:25:39 +0900

> On MIPv6 usage, XFRM sub policy is enabled.
> When main (IPsec) and sub (MIPv6) policy selectors have the same
> address set but different upper layer information (i.e. protocol
> number and its ports or type/code), multiple bundle should be created.
> However, currently we have issue to use the same bundle created for
> the first time with all flows covered by the case.
> 
> It is useful for the bundle to have the upper layer information
> to be restructured correctly if it does not match with the flow.
> 
> 1. Bundle was created by two policies
> Selector from another policy is added to xfrm_dst.
> If the flow does not match the selector, it goes to slow path to
> restructure new bundle by single policy.
> 
> 2. Bundle was created by one policy
> Flow cache is added to xfrm_dst as originated one. If the flow does
> not match the cache, it goes to slow path to try searching another
> policy.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

This is an OK solution for the problem for now.

My senses tell me that there is probably some cleaner way to
handle this problem.  If you come up with a better idea for it,
please feel free to bounce your ideas to me.

Thanks.
