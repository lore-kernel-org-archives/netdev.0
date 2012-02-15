From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Enforce minimum size of VETH_INFO_PEER
Date: Wed, 15 Feb 2012 14:59:49 -0500 (EST)
Message-ID: <20120215.145949.1953176562971846062.davem@davemloft.net>
References: <1329314986-20320-1-git-send-email-tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab2BOUBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 15:01:06 -0500
In-Reply-To: <1329314986-20320-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 15 Feb 2012 15:09:46 +0100

> VETH_INFO_PEER carries struct ifinfomsg plus optional IFLA
> attributes. A minimal size of sizeof(struct ifinfomsg) must be
> enforced or we may risk accessing that struct beyond the limits
> of the netlink message.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied and queued up for -stable, thanks Thomas.
