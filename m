From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] rxrpc: More fixes and adjustments
Date: Mon, 03 Oct 2016 02:02:36 -0400 (EDT)
Message-ID: <20161003.020236.1905952240188445872.davem@davemloft.net>
References: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 30 Sep 2016 22:40:11 +0100

> 
> This set of patches contains some more fixes and adjustments:
> 
>  (1) Actually display the retransmission indication previously added to the
>      tx_data trace.
> 
>  (2) Switch to Congestion Avoidance mode properly at cwnd==ssthresh rather
>      than relying on detection during an overshoot and correction.
> 
>  (3) Reduce ssthresh to the peer's declared receive window.
> 
>  (4) The offset field in rxrpc_skb_priv can be dispensed with and the error
>      field is no longer used.  Get rid of them.
> 
>  (5) Keep the call timeouts as ktimes rather than jiffies to make it easier
>      to deal with RTT-based timeout values in future.  Rounding to jiffies
>      is still necessary when the system timer is set.
> 
>  (6) Fix the call timer handling to avoid retriggering of expired timeout
>      actions.
 ...
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160930

Pulled, thanks David.
