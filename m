From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: Add IPPROTO_GRE to flowi in ipgre_tunnel_xmit
Date: Fri, 11 Feb 2011 11:23:25 -0800 (PST)
Message-ID: <20110211.112325.115923664.davem@davemloft.net>
References: <20110211093040.GB29583@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59703
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756787Ab1BKTWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 14:22:49 -0500
In-Reply-To: <20110211093040.GB29583@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 11 Feb 2011 10:30:40 +0100

> Commit 5811662b15db018c740c57d037523683fd3e6123 accidentally
> removed the setting of IPPROTO_GRE from the struct flowi
> in ipgre_tunnel_xmit. This patch restores it.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied and queued up for -stable, thanks!
