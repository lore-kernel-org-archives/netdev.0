From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [NETLINK]: Dont set socket error for failed event
 notifications
Date: Thu, 10 Aug 2006 23:02:42 -0700 (PDT)
Message-ID: <20060810.230242.42459982.davem@davemloft.net>
References: <20060810190455.GI14627@postel.suug.ch>
	<44DB8425.8020108@trash.net>
	<20060810192323.GJ14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48613
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750984AbWHKGCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:02:35 -0400
To: tgraf@suug.ch
In-Reply-To: <20060810192323.GJ14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 10 Aug 2006 21:23:23 +0200

> Dave, please revert the whole patchset.

Done and I've rebased the net-2.6.19 tree as well at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.19.git

Thomas, there was a conflict which I did expect since I added
all the 2.6.18 bug fixes into the tree.  The conflict is for
your netlink conversion of the iflink stuff.

I had to fix the -stable tree IFLA_ADDRESS handling because
dev->set_mac_address expects a sockaddr not a raw MAC
address.

I think I resolved the conflict while applying the patch
properly, but if you could take a look I'd appreciate it.

Thanks.
