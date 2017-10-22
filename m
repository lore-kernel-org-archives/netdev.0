From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rxrpc: Don't release call mutex on error pointer
Date: Sun, 22 Oct 2017 03:06:24 +0100 (WEST)
Message-ID: <20171022.030624.2302188182510801616.davem@davemloft.net>
References: <150851528227.19340.4842940319829659889.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150851528227.19340.4842940319829659889.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 20 Oct 2017 17:01:22 +0100

> Don't release call mutex at the end of rxrpc_kernel_begin_call() if the
> call pointer actually holds an error value.
> 
> Fixes: 540b1c48c37a ("rxrpc: Fix deadlock between call creation and sendmsg/recvmsg")
> Reported-by: Marc Dionne <marc.dionne@auristor.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
