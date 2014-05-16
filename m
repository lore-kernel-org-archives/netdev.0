From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_rxrpc: Fix XDR length check in rxrpc key
 demarshalling.
Date: Fri, 16 May 2014 15:25:20 -0400 (EDT)
Message-ID: <20140516.152520.1325547885798958983.davem@davemloft.net>
References: <20140515145122.29177.65285.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nwf@cs.jhu.edu,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140515145122.29177.65285.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 15 May 2014 15:51:22 +0100

> From: Nathaniel W Filardo <nwf@cs.jhu.edu>
> 
> There may be padding on the ticket contained in the key payload, so just ensure
> that the claimed token length is large enough, rather than exactly the right
> size.
> 
> Signed-off-by: Nathaniel Wesley Filardo <nwf@cs.jhu.edu>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks.
