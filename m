From: David Miller <davem@davemloft.net>
Subject: net-2.6.24 plans
Date: Sun, 16 Sep 2007 20:22:58 -0700 (PDT)
Message-ID: <20070916.202258.03371690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751969AbXIQDW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 23:22:59 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0E7F92900FE
	for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 20:22:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Most if not all of my 2 week backlog of patches is in the net-2.6.24
and net-2.6 tree now.  And any relevant -stable fixes will be
submitted in the next day or two.

Tomorrow (Monday) I want to rebase the net-2.6.24 tree one more time
to deal with all of the conflicts which exist between
linux-2.6/net-2.6 and net-2.6.24, but I'll likely defer that
until the net-2.6 fixes I just pushed to Linus are integrated.

It's to the point where every single bug fix put into Linus's tree
creates a merge conflict with net-2.6.24, we are simply touching that
much stuff. :-)

I expect some small network namespace fixes from Eric B., but that's
basically it as far as 2.6.24 is concerned.  Oh yes, there are also
the MAC_FMT/MAC_ARG bits from Joe Perches that I need to do a merge
of.

The transmit batching stuff needs a lot more analysis and discussion,
so I definitely see that stuff as 2.6.25 material.  I think if we can
avoid a food fight between Jamal and Mr. Kumar and have healthy
discussions, we can end up with a really nice implementation.  So
everyone put your boxing gloves away and let's get at it. :-)

We've touched so much in net-2.6.24 that we really should be auditing
the thing and fixing any bugs that have been added.  If you're bored
and looking for something to do, pick an odd NAPI driver and audit it
in the net-2.6.24 tree.
