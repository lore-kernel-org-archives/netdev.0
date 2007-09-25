From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Tue, 25 Sep 2007 14:09:10 -0700 (PDT)
Message-ID: <20070925.140910.41653604.davem@davemloft.net>
References: <ygfr6kmev3i.fsf@janus.isnogud.escape.de>
	<20070925083303.6c1f7701@freepuppy.rosehill>
	<ygfejgmea00.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, joe@perches.com, tglx@linutronix.de,
	oliver@hartkopp.net, oliver.hartkopp@volkswagen.de
To: urs@isnogud.escape.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755276AbXIYVel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 17:34:41 -0400
In-Reply-To: <ygfejgmea00.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Urs Thuermann <urs@isnogud.escape.de>
Date: 25 Sep 2007 23:00:15 +0200

> Stephen Hemminger <shemminger@linux-foundation.org> writes:
> 
> > Then please make all exported symbols marked EXPORT_SYMBOL_GPL to make
> > sure that the other CAN protocol can not reuse your infrastructure.
> 
> We don't want to force other CAN protocol implementations to be GPL
> also.  AFAIR from discussions on LKML, it was mostly agreed upon that
> this decision is up to the authors of code.

To a certain extent, yes.

However, the core issue is whether anyone who uses the symbol
is creating a derivative work.  If it is pretty clear that this
is the case, you really should mark the exported symbols GPL.

In my opinion, in this case it is pretty clear that any use of
these new symbols would be a derivative work and therefore they
all should be marked GPL.
