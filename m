From: David Miller <davem@davemloft.net>
Subject: Re: [RTNETLINK 02/04]: Hold rtnl_mutex during netlink dump
 callbacks
Date: Mon, 16 Apr 2007 16:59:20 -0700 (PDT)
Message-ID: <20070416.165920.77404735.davem@davemloft.net>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
	<20070416074951.19262.57226.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33011
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754057AbXDPX7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 19:59:18 -0400
In-Reply-To: <20070416074951.19262.57226.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 16 Apr 2007 09:51:54 +0200 (MEST)

> [RTNETLINK]: Hold rtnl_mutex during netlink dump callbacks
> 
> Hold rtnl_mutex during the entire netlink dump operation. This allows
> to simplify locking in the dump callbacks, since they can now rely on
> that no concurrent changes happen.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
