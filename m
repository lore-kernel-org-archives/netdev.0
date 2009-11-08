From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: fix WARN_ON dump in
 net/core/rtnetlink.c:rtmsg_ifinfo()
Date: Sun, 08 Nov 2009 00:46:02 -0800 (PST)
Message-ID: <20091108.004602.213063654.davem@davemloft.net>
References: <4AF54389.1090309@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33130
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752035AbZKHIpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 03:45:36 -0500
In-Reply-To: <4AF54389.1090309@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Sat, 07 Nov 2009 10:53:13 +0100

> On older kernels, e.g. 2.6.27, a WARN_ON dump in rtmsg_ifinfo()
> is thrown when the CAN device is registered due to insufficient
> skb space, as reported by various users. This patch adds the
> rtnl_link_ops "get_size" to fix the problem. I think this patch
> is required for more recent kernels as well, even if no WARN_ON
> dumps are triggered. Maybe we also need "get_xstats_size" for
> the CAN xstats.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied to net-2.6, thanks Wolfgang.
