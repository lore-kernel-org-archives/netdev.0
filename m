From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (take 2)] netdev: lockdep classes in register_netdevice
 Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Tue, 15 May 2007 22:47:25 -0700 (PDT)
Message-ID: <20070515.224725.95062491.davem@davemloft.net>
References: <20070514060700.GA1000@ff.dom.local>
	<20070513.233937.99203647.davem@davemloft.net>
	<20070516054000.GB967@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761111AbXEPFrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 01:47:20 -0400
In-Reply-To: <20070516054000.GB967@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Wed, 16 May 2007 07:40:00 +0200

> After initializing dev->_xmit_lock register_netdevice()
> sets lockdep class according to dev->type.
> 
> Idea of this patch - by David Miller.
> 
> Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

Patch applied, dziekuje bardzo.
