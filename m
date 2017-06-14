From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: Cache the congestion window setting
Date: Wed, 14 Jun 2017 15:43:10 -0400 (EDT)
Message-ID: <20170614.154310.849323406453518301.davem@davemloft.net>
References: <149745941093.31933.4996708684908629747.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149745941093.31933.4996708684908629747.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Wed, 14 Jun 2017 17:56:50 +0100

> Cache the congestion window setting that was determined during a call's
> transmission phase when it finishes so that it can be used by the next call
> to the same peer, thereby shortcutting the slow-start algorithm.
> 
> The value is stored in the rxrpc_peer struct and is accessed without
> locking.  Each call takes the value that happens to be there when it starts
> and just overwrites the value when it finishes.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
