From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH?] Fix call to ->change_rx_flags(dev, IFF_MULTICAST) in
 dev_change_flags()
Date: Tue, 20 May 2008 14:36:41 -0700 (PDT)
Message-ID: <20080520.143641.122144468.davem@davemloft.net>
References: <1211285486.21380.204.camel@pmac.infradead.org>
	<4832C864.8020605@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755234AbYETVgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:36:45 -0400
In-Reply-To: <4832C864.8020605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 20 May 2008 14:47:32 +0200

> David Woodhouse wrote:
> > Am I just being particularly dim today, or can the call to
> > dev->change_rx_flags(dev, IFF_MULTICAST) in dev_change_flags() never
> > happen?
> > 
> > We've just set dev->flags = flags & IFF_MULTICAST, effectively. So the
> > condition '(dev->flags ^ flags) & IFF_MULTICAST' is _never_ going to be
> > true.
> 
> Thanks for catching this, you're correct of course.

Applied and queued to -stable, thanks everyone!
