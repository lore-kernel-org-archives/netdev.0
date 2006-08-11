From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event
 notifications
Date: Fri, 11 Aug 2006 03:42:17 -0700 (PDT)
Message-ID: <20060811.034217.129782959.davem@davemloft.net>
References: <20060810192323.GJ14627@postel.suug.ch>
	<20060810.230242.42459982.davem@davemloft.net>
	<20060811103822.GN14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31880
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932112AbWHKKmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 06:42:09 -0400
To: tgraf@suug.ch
In-Reply-To: <20060811103822.GN14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 11 Aug 2006 12:38:22 +0200

> Looks good. You could have used nla_memcpy() instead of
> memcpy() but there is no functional difference in this case.

Right, because the code already verifies that the attribute
length is at least dev->addr_len, and that is the size of
the memcpy we do.

Thanks for checking things out.
