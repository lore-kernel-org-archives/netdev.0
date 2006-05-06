From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [SCTP]: Fix panic's when receiving fragmented SCTP
 control chunks.
Date: Fri, 05 May 2006 17:04:51 -0700 (PDT)
Message-ID: <20060505.170451.81381431.davem@davemloft.net>
References: <1146856485.7861.35.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42189
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751237AbWEFAFC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 20:05:02 -0400
To: sri@us.ibm.com
In-Reply-To: <1146856485.7861.35.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 05 May 2006 12:14:45 -0700

> [SCTP]: Fix panic's when receiving fragmented SCTP control chunks.
> 
> Use pskb_pull() to handle incoming COOKIE_ECHO and HEARTBEAT chunks that
> are received as skb's with fragment list.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
