From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 15:11:44 -0700 (PDT)
Message-ID: <20070919.151144.59833230.davem@davemloft.net>
References: <20070918.151528.84360712.davem@davemloft.net>
	<20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
	<46F19D25.2010403@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751424AbXISWLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:11:44 -0400
In-Reply-To: <46F19D25.2010403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 19 Sep 2007 18:05:25 -0400

> That said, the 2-arg macro arg order is wrong.  It should be (reg,val) 
> like tg3 and other drivers.

I actually wanted to mirror the ordering that
writel() uses.

So the choice is arbitrary, either be consistent with
our well established asm/io.h interfaces or a bunch
of network driver :-)
