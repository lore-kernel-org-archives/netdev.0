From: David Miller <davem@davemloft.net>
Subject: Re: [iproute2] iproute2: Allow 'ip addr flush' to loop more than
 10 times.
Date: Tue, 29 Jun 2010 10:02:26 -0700 (PDT)
Message-ID: <20100629.100226.235686154.davem@davemloft.net>
References: <4C29925B.9090008@candelatech.com>
	<20100628.233600.242129599.davem@davemloft.net>
	<4C2A0CF3.9020204@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@gmail.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932229Ab0F2RCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 13:02:13 -0400
In-Reply-To: <4C2A0CF3.9020204@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 29 Jun 2010 08:10:43 -0700

> If I understand your proposal properly, this would seem to be
> somewhat O(N^2) if we have large numbers of addresses, and I'm
> hoping to support thousands of IPs with decent performance.

I am not modifying the computational complexity or cost of the
operation at all.

I'm just changing under what circumstances it gives up.

> What do you think about improving the kernel side so that we can send
> a single netlink msg to delete all addresses on an interface, and just
> let the kernel do the looping/locking needed to make it happen?

I think the current scheme isn't that bad.
