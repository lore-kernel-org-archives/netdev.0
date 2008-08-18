From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 16:56:38 -0700 (PDT)
Message-ID: <20080818.165638.169012226.davem@davemloft.net>
References: <20080818113531.GB7158@ff.dom.local>
	<200808181545.30146.denys@visp.net.lb>
	<20080818125805.GA7938@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753307AbYHRX4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 19:56:39 -0400
In-Reply-To: <20080818125805.GA7938@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 18 Aug 2008 12:58:05 +0000

> On Mon, Aug 18, 2008 at 03:45:29PM +0300, Denys Fedoryshchenko wrote:
> > Patch applied, got another warning.
> 
> I hope I'll figure this out before evening. Probably it's safer
> to stop testing for a while.

We have to put the kfree() of the qdisc back into an RCU handler,
that's all.

I'll cook up a patch for that.
