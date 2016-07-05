From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH net-next 06/24] rxrpc: Dup the main conn list for the proc interface
Date: Tue, 05 Jul 2016 20:21:38 +0100
Message-ID: <14829.1467746498@warthog.procyon.org.uk>
References: <20160705.101745.2191999709401594106.davem@davemloft.net> <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk> <146772437424.21657.5653571141789810019.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbcGETVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 15:21:40 -0400
In-Reply-To: <20160705.101745.2191999709401594106.davem@davemloft.net>
Content-ID: <14828.1467746498.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

> Wouldn't it be better to just code the proc stuff to walk whatever
> table the rest of the stack uses to hold all of the connections
> as TCP et al. do?

There won't be "a table" that the rest of the stack uses.  There will be more
than one.  Service conns and client conns will be handled separately, they
will have different lifecycle strategies, different lifetimes and separate
object handling code.  It's almost worth actually having separate structs for
them, but there's sufficient common ground that it doesn't actually make
sense, I think.

David
