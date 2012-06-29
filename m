From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use NLMSG_DEFAULT_SIZE in combination with
 nlmsg_new()
Date: Thu, 28 Jun 2012 17:57:02 -0700 (PDT)
Message-ID: <20120628.175702.1160710702612954949.davem@davemloft.net>
References: <caecbaa2f181c17908fbd61264e1acb9c5cb1fe1.1340891841.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpirko@redhat.com, dbaryshkov@gmail.com,
	slapin@ossfans.org, johannes@sipsolutions.net,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754608Ab2F2A5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 20:57:03 -0400
In-Reply-To: <caecbaa2f181c17908fbd61264e1acb9c5cb1fe1.1340891841.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 28 Jun 2012 15:57:45 +0200

> Using NLMSG_GOODSIZE results in multiple pages being used as
> nlmsg_new() will automatically add the size of the netlink
> header to the payload thus exceeding the page limit.
> 
> NLMSG_DEFAULT_SIZE takes this into account.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
