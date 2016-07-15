From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rxrpc: checking for IS_ERR() instead of NULL
Date: Fri, 15 Jul 2016 14:16:41 -0700 (PDT)
Message-ID: <20160715.141641.2297591667441294954.davem@davemloft.net>
References: <146850762158.24833.7534163896673339680.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	dan.carpenter@oracle.com, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146850762158.24833.7534163896673339680.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 14 Jul 2016 15:47:01 +0100

> From: Dan Carpenter <dan.carpenter@oracle.com>
> 
> The rxrpc_lookup_peer() function returns NULL on error, it never returns
> error pointers.
> 
> Fixes: 8496af50eb38 ('rxrpc: Use RCU to access a peer's service connection tree')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
