From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ROSE] packet routing improvement
Date: Mon, 14 Feb 2011 13:33:08 -0800 (PST)
Message-ID: <20110214.133308.246523629.davem@davemloft.net>
References: <4D596B25.9080309@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, f6bvp@free.fr
To: bpidoux@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45553
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093Ab1BNVcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 16:32:32 -0500
In-Reply-To: <4D596B25.9080309@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard Pidoux <bpidoux@free.fr>
Date: Mon, 14 Feb 2011 18:49:25 +0100

> [PATCH] [ROSE] rose AX25 packet routing improvement
> 
> FPAC AX25 packet application is using Linux kernel ROSE
> routing skills in order to connect or send packets to remote stations
> knowing their ROSE address via a network of interconnected nodes.
> 
> Each FPAC node has a ROSE routing table that Linux ROSE module is
> looking at each time a ROSE frame is relayed by the node or when
> a connect request to a neighbor node is received.
> 
> A previous patch improved the system time response by looking at
> already established routes each time the system was looking for a
> route to relay a frame. If a neighbor node routing the destination
> address was already connected, then the frame would be sent
> through him. If not, a connection request would be issued.
> 
> The present patch extends the same routing capability to a connect
> request asked by a user locally connected into an FPAC node.
> Without this patch, a connect request was not well handled unless it
> was directed to an immediate connected neighbor of the local node.
> 
> Implemented at a number of ROSE FPAC node stations, the present patch
> improved dramatically FPAC ROSE routing time response and efficiency.
> 
> Signed-off-by: Bernard Pidoux <f6bvp@free.fr>

Applied to net-next-2.6

