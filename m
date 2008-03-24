From: David Miller <davem@davemloft.net>
Subject: net GIT tree status
Date: Sun, 23 Mar 2008 23:13:05 -0700 (PDT)
Message-ID: <20080323.231305.122181400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43679
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752968AbYCXGNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 02:13:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A6B89C8C340
	for <netdev@vger.kernel.org>; Sun, 23 Mar 2008 23:13:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've queued up several bug fixes into net-2.6 and just asked Linus to
pull them in.

I merged net-2.6 into net-2.6.26 and resolved the merge conflicts.  It
passes an allmodconfig build but I haven't done much more with it,
please handle with care.

I have only a small amount of stuff now in my backlog, a couple
lockdep from changes Peter Zijlstra and Gautham R Shenoy I still can't
understand, some IPV6 semantic changes from Benoit Boissinot which I'd
really like an IPV6 expert to look at.

Finally I have to re-review Denis's inet6_dev handling cures as well
as look at Eric's most recent netif_receive_skb() loopback "hacks" :-)
