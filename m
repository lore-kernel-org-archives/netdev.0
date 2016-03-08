From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Tue, 08 Mar 2016 15:13:11 -0500 (EST)
Message-ID: <20160308.151311.928321529565045584.davem@davemloft.net>
References: <20160307143806.18567.30020.stgit@warthog.procyon.org.uk>
	<23389.1457390714@warthog.procyon.org.uk>
	<29908.1457437197@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <29908.1457437197@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 08 Mar 2016 11:39:57 +0000

> One could argue, I suppose, that things should've been arranged that the RxRPC
> client would manage the lifetime of each connection it sets up, rather than
> both ends letting it lapse by mutual loss of interest.  But you *still* have to
> have a timeout, lest the client die and not close its connection.

But the point is if there is no limitation on the number of these connections
that can be setup.... wait for troubles.

And if you try to put in some kind of limit to handle this, it's then
easy for the bad guy to block out other legitimate users.
