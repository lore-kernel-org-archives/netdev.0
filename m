From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 05/24] rxrpc: Provide more refcount helper functions
Date: Tue, 05 Jul 2016 20:50:20 +0100
Message-ID: <17463.1467748220@warthog.procyon.org.uk>
References: <20160705.101636.1426176903162735420.davem@davemloft.net> <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk> <146772436726.21657.7089071379028604342.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160705.101636.1426176903162735420.davem@davemloft.net>
Content-ID: <17462.1467748220.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> I don't see anything in this patch dealing with refcount helper functions.

I'm amending the patch description to:

    rxrpc: Provide queuing helper functions
    
    Provide queueing helper functions so that the queueing of local and
    connection objects can be fixed later.
    
    The issue is that a ref on the object needs to be passed to the work queue,
    but the act of queueing the object may fail because the object is already
    queued.  Testing the queuedness of an object before hand doesn't work
    because there can be a race with someone else trying to queue it.  What
    will have to be done is to adjust the refcount depending on the result of
    the queue operation.
    
    Signed-off-by: David Howells <dhowells@redhat.com>

but not changing the patch.

David
