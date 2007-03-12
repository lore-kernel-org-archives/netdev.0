From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NetLabel: parse the CIPSO ranged tag on incoming
 packets
Date: Mon, 12 Mar 2007 14:37:44 -0700 (PDT)
Message-ID: <20070312.143744.95894914.davem@davemloft.net>
References: <20070312134615.294091233@flek.zko.hp.com>
	<Line.LNX.4.64.0703121050180.9351@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932436AbXCLVhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 17:37:48 -0400
In-Reply-To: <Line.LNX.4.64.0703121050180.9351@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Mon, 12 Mar 2007 10:50:41 -0400 (EDT)

> On Mon, 12 Mar 2007, Paul Moore wrote:
> 
> > Commit 484b366932be0b73a22c74a82748ca10a721643e added support for the CIPSO
> > ranged categories tag.  However, it appears that I made a mistake when rebasing
> > then patch to the latest upstream sources for submission and dropped the part
> > of the patch that actually parses the tag on incoming packets.  This patch
> > fixes this mistake by adding the required function call to the
> > cipso_v4_skbuff_getattr() function.
> > 
> > I've run this patch over the weekend and have not noticed any problems.
> > 
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> Acked-by: James Morris <jmorris@namei.org>

Applied, thanks guys.
