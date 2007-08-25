From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6] XFRM: Fix connected socket to use
 transformation.
Date: Fri, 24 Aug 2007 23:31:53 -0700 (PDT)
Message-ID: <20070824.233153.77246332.davem@davemloft.net>
References: <118795011877-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takamiya@po.ntts.co.jp
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756074AbXHYGby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:31:54 -0400
In-Reply-To: <118795011877-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 24 Aug 2007 19:08:38 +0900

> When XFRM policy and state are ready after TCP connection is started,
> the traffic should be transformed immediately, however it does not
> on IPv6 TCP.
> 
> It depends on a dst cache replacement policy with connected socket.
> It seems that the replacement is always done for IPv4, however, on
> IPv6 case it is done only when routing cookie is changed.
> 
> This patch fix that non-transformation dst can be changed to
> transformation one.
> This behavior is required by MIPv6 and improves IPv6 IPsec.
> 
> Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Applied to net-2.6.24, thank you!
