From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] rxrpc: Rework endpoint record handling
Date: Wed, 15 Jun 2016 22:25:44 -0700 (PDT)
Message-ID: <20160615.222544.2267833888306477526.davem@davemloft.net>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Wed, 15 Jun 2016 17:41:38 +0100

> Here's the next part of the AF_RXRPC rewrite.  In this set I rework
> endpoint record handling.  There are two types of endpoint record, local
> and peer.  The local endpoint record is used as an anchor for the transport
> socket that AF_RXRPC uses (at the moment a UDP socket).  Local endpoints
> can be shared between AF_RXRPC sockets under certain restricted
> circumstances.
> 
> The peer endpoint is a record of the remote end.  It is (or will be) used
> to keep track MTU and RTT values and, with these changes, is used to find
> the call(s) to abort when a network error occurs.
> 
> The following significant changes are made:
 ...
> The patches can be found here also:
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160615

Pulled, thanks David.
