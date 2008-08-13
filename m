From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix oops in htb_delete.
Date: Wed, 13 Aug 2008 15:16:55 -0700 (PDT)
Message-ID: <20080813.151655.261020658.davem@davemloft.net>
References: <20080813201259.GA4350@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753183AbYHMWQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 18:16:53 -0400
In-Reply-To: <20080813201259.GA4350@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 13 Aug 2008 22:13:00 +0200

> pkt_sched: Fix oops in htb_delete.
> 
> Recent changes introduced a bug in htb_delete(): cl->parent->children
> counter update misses checking cl->parent for NULL, which is used for
> root classes, so deleting them causes an oops.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks Jarek.
