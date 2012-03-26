From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/vlan: withdraw VLAN ID attribute from GVRP on VLAN
 device stop
Date: Mon, 26 Mar 2012 17:42:16 -0400 (EDT)
Message-ID: <20120326.174216.151181141269420661.davem@davemloft.net>
References: <4F707163.2000209@ll.mit.edu>
	<4F7087CA.5010804@dti2.net>
	<4F709038.20107@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jorge@dti2.net, netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab2CZVmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 17:42:25 -0400
In-Reply-To: <4F709038.20107@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Date: Mon, 26 Mar 2012 11:50:16 -0400

> If I create an interface that is initially down, then bring it up, and
> finally bring it back down, I think it should return to the state it
> was in initially.  So in my opinion, either the GVRP attribute should
> exist while the interface is down, or it shouldn't.

You're whole argument breaks down because we definitely don't do this
for IPv4 addresses, we'll keep receiving traffic for IPv4 addresses
configured on that interface when received on other interfaces which
are still up, even when you bring that interface down.

Really, if you want to leave GVRP, unconfigure it.

I'm not applying this patch.
