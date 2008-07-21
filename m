From: David Miller <davem@davemloft.net>
Subject: Re: [crash] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 12:00:52 -0700 (PDT)
Message-ID: <20080721.120052.123606398.davem@davemloft.net>
References: <20080721134506.GA27598@elte.hu>
	<20080721182318.GA20940@elte.hu>
	<alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752712AbYGUTAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 15:00:53 -0400
In-Reply-To: <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 21 Jul 2008 11:35:21 -0700 (PDT)

> Maybe the network drivers are few enough that it will get fixed, or
> maybe the WARN_ON_ONCE() will just be removed and the rule not
> reinforced.
> 
> I personally suspect the latter, since it seems to happen with just
> about _any_ random network driver, including the common and
> well-maintained ones (ie the Gods only help us for the truly
> odd/random cases)

Yes, we'll see how this plays out.

Ian Schram just posted a patch for the NULL pointer derfer in
wireless Ingo reported, so we'll see if that bug will be fixed
now as well.
