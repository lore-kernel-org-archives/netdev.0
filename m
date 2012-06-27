From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Assign rtnl_link_ops to bridge devices created
 via ioctl (v2)
Date: Tue, 26 Jun 2012 21:13:10 -0700 (PDT)
Message-ID: <20120626.211310.1141495657985558140.davem@davemloft.net>
References: <20120626075940.099521a7@nehalam.linuxnetplumber.net>
	<20120626151311.GB31808@canuck.infradead.org>
	<20120626084845.0578fcb8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab2F0ENL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 00:13:11 -0400
In-Reply-To: <20120626084845.0578fcb8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 26 Jun 2012 08:48:45 -0700

> This ensures that bridges created with brctl(8) or ioctl(2) directly
> also carry IFLA_LINKINFO when dumped over netlink. This also allows
> to create a bridge with ioctl(2) and delete it with RTM_DELLINK.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> v2 - Minor change to Thomas's original patch.
> This is a bug fix, should go to stable as well.

Applied and queued up for -stable, thanks.
