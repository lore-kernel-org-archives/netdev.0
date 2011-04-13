From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NET-2.6 1/1] qlcnic: limit skb frags for non tso
 packet
Date: Wed, 13 Apr 2011 11:53:53 -0700 (PDT)
Message-ID: <20110413.115353.246527102.davem@davemloft.net>
References: <1302663955-31849-1-git-send-email-amit.salecha@qlogic.com>
	<1302663955-31849-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, stable@kernel.org
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757251Ab1DMSy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:54:28 -0400
In-Reply-To: <1302663955-31849-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Tue, 12 Apr 2011 20:05:55 -0700

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> Machines are getting deadlock in four node cluster environment.
> All nodes are accessing (find /gfs2 -depth -print|cpio -ocv > /dev/null)
> 200 GB storage on a GFS2 filesystem.
> This result in memory fragmentation and driver receives 18 frags for
> 1448 byte packets.
> For non tso packet, fw drops the tx request, if it has >14 frags.
> 
> Fixing it by pulling extra frags.
> 
> Cc: stable@kernel.org
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.

But like Greg said, please kill that footer notice on your outgoing
emails when engaging in any discussion on a public mailing list.

Thanks.
