From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 18:08:10 -0400 (EDT)
Message-ID: <20130408.180810.204547968236959718.davem@davemloft.net>
References: <2921619.mqaHl5PnPI@sifl>
	<20130408.173325.1683493727549657170.davem@davemloft.net>
	<2162769.UZ73yv7g6c@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: pmoore@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <2162769.UZ73yv7g6c@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <pmoore@redhat.com>
Date: Mon, 08 Apr 2013 18:01:56 -0400

> Okay, if the objection is really just one of structure size and not the hooks, 
> what if I did the work to consolidate the skb->secmark and skb->sp fields into 
> a new structure/pointer?  Assuming it wasn't too painful, it would be a net 
> reduction of four bytes.  If that worked would you have an objection to us 
> adding a LSM security blob to this new structure?

'sp' is sepreate from LSM and making it indirect would hurt IPSEC
performance.

Please, really, just drop this.

Thanks.
