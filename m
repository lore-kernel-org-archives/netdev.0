From: David Miller <davem@davemloft.net>
Subject: Re: macvlan/macvtap patch in patchwork
Date: Sun, 02 Oct 2011 20:33:06 -0400 (EDT)
Message-ID: <20111002.203306.17836844704730738.davem@davemloft.net>
References: <20110927.151415.1749891588648068894.davem@davemloft.net>
	<4E825804.2010603@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	herbert@gondor.hengli.com.au, krkumar2@in.ibm.com
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552Ab1JCAeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 20:34:25 -0400
In-Reply-To: <4E825804.2010603@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Date: Tue, 27 Sep 2011 19:11:00 -0400

> The problem is that I was forwarding the frame to the lowerdev the
> wrong way, by calling vlan->forward which serves a different purpose.
> vlan->forward points to dev_forward_skb for macvlan (so the forwarding
> works fine), but it points to macvtap_forward for macvtap (which
> causes an oops when called here).  We need to always use
> dev_forward_skb to forward to a lowerdev.

Thanks for explaining, patch applied.
