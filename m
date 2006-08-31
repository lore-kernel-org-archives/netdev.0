From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix typo causing wrong skb to be freed
Date: Thu, 31 Aug 2006 15:05:00 -0700 (PDT)
Message-ID: <20060831.150500.25213839.davem@davemloft.net>
References: <20060831212650.GG3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28345
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964790AbWHaWEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:04:55 -0400
To: tgraf@suug.ch
In-Reply-To: <20060831212650.GG3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 31 Aug 2006 23:26:51 +0200

> A typo introduced by myself which leads to freeing the skb
> containing the netlink message when it should free the newly
> allocated skb for the reply.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
