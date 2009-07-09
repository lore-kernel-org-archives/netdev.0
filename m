From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Wed, 08 Jul 2009 20:08:52 -0700 (PDT)
Message-ID: <20090708.200852.15061282.davem@davemloft.net>
References: <20090708144744.5555b88d.akpm@linux-foundation.org>
	<20090708222003.GA12318@oksana.dev.rtsoft.ru>
	<alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, akpm@linux-foundation.org,
	a.p.zijlstra@chello.nl, oleg@redhat.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756824AbZGIDIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 23:08:49 -0400
In-Reply-To: <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 8 Jul 2009 17:01:14 -0700 (PDT)

> So ACK on Anton's patch,

I'll integrate it into my tree, thanks.

> but I wonder if we _also_ should do the following?

I think we should set SYSTEM_RUNNING earlier, makes sense
to me.
