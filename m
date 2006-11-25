From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] STATE: Fix to respond error to get operation if
 no matching entry exists.
Date: Fri, 24 Nov 2006 20:35:13 -0800 (PST)
Message-ID: <20061124.203513.112983202.davem@davemloft.net>
References: <11644286393508-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:18365
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966225AbWKYEfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 23:35:10 -0500
To: nakam@linux-ipv6.org
In-Reply-To: <11644286393508-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 25 Nov 2006 13:23:59 +0900

> When application uses XFRM_MSG_GETSA to get state entry through netlink
> socket and kernel has no matching one, the application expects reply
> message with error status by kernel.
> 
> Kernel doesn't send the message back in the case of Mobile IPv6 route
> optimization protocols (i.e. routing header or destination options
> header). This is caused by incorrect return code "0" from
> net/xfrm/xfrm_user.c(xfrm_user_state_lookup) and it makes kernel skip to
> acknowledge at net/netlink/af_netlink.c(netlink_rcv_skb).
> 
> This patch fix to reply ESRCH to application.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: TAKAMIYA Noriaki <takamiya@po.ntts.co.jp>

Patch applied, thank you very much.
