From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] Socket filter ancilliary data access for
 skb->dev->type
Date: Thu, 22 Apr 2010 16:06:05 -0700 (PDT)
Message-ID: <20100422.160605.83866642.davem@davemloft.net>
References: <20100422133222.GU19334@cel.leo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leonerd@leonerd.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753704Ab0DVXGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 19:06:00 -0400
In-Reply-To: <20100422133222.GU19334@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Date: Thu, 22 Apr 2010 14:32:22 +0100

> Add an SKF_AD_HATYPE field to the packet ancilliary data area, giving
> access to skb->dev->type, as reported in the sll_hatype field.
> 
> When capturing packets on a PF_PACKET/SOCK_RAW socket bound to all
> interfaces, there doesn't appear to be a way for the filter program to
> actually find out the underlying hardware type the packet was captured
> on. This patch adds such ability.
> 
> This patch also handles the case where skb->dev can be NULL, such as on
> netlink sockets.
> 
> Signed-off-by: Paul Evans <leonerd@leonerd.org.uk>

Looks good, applied to net-next-2.6, thanks!
