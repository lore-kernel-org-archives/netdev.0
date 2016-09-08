From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] rxrpc: Overhaul call refcounting
Date: Wed, 07 Sep 2016 17:22:16 -0700 (PDT)
Message-ID: <20160907.172216.1425039504750660925.davem@davemloft.net>
References: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbcIHAWX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 20:22:23 -0400
In-Reply-To: <147326174610.26593.17043098689515647894.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Wed, 07 Sep 2016 16:22:26 +0100

> 
> Here's a set of mostly small patches leading up to one big one.
> 
> The big patch at the end of the series overhauls how rxrpc_call refcounting
> is handled, making it more sane so that calls bound to user IDs are _only_
> released from socket operations or kernel API functions.  Further, the
> patch stops calls from holding refs on their parent socket - which can
> prevent the socket from being cleaned up.
> 
> The second largest patch improves the call tracking tracepoint by providing
> extra information about the situation in which gets and puts occur.  This
> allows distinctions to be drawn between refs held by the socket user ID
> tree, refs held by the work queue (to be implemented by a future patch) and
> other refs.
> 
> The other patches include a couple of cleanups and some simple alterations
> to avoid NULL pointer dereferences in the big patch.
> 
> The patches can be found here also (non-terminally on the branch):
> 
> 	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite
> 
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20160907-1

Pulled.
