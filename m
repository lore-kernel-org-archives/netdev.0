From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/6] s390: qeth fixes for 2.6.30
Date: Wed, 25 Mar 2009 00:08:17 -0700 (PDT)
Message-ID: <20090325.000817.183932373.davem@davemloft.net>
References: <20090325065713.054133000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756099AbZCYHIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:08:30 -0400
In-Reply-To: <20090325065713.054133000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Wed, 25 Mar 2009 07:57:13 +0100

> here are a couple of qeth fixes for 2.6.30

Any particular reason you wait until right when the
merge window opens to send me stuff?

I said on netdev that I wanted to empty my patchwork
queue then submit the tree to Linus.

So then you send me more stuff on top of that? :-/

Please don't wait until the last moment next time.

> shortlog:
> Kay Sievers (1)
> qeth: struct device - replace bus_id with dev_name(), dev_set_name()

Applied.

> Klaus-Dieter Wacker (1)
> qeth: unregister MAC addresses during recovery

Applied.

> Ursula Braun (1)
> qeth: check for completion of a running recovery

Applied.

> Heiko Carstens(1)
> qeth: fix wait_event_timeout handling

Applied.

> Frank Blaschka (2)
> qeth: add statistics for tx csum
> qeth: remove EDDP

Your EDDP was slow because the implementation was incredibly
sub-optimal.  %90 of the code is doing copies and fiddling
with SKB internals.
