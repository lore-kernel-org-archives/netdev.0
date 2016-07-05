From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/24] rxrpc: Dup the main conn list for the
 proc interface
Date: Tue, 05 Jul 2016 10:17:45 -0700 (PDT)
Message-ID: <20160705.101745.2191999709401594106.davem@davemloft.net>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
	<146772437424.21657.5653571141789810019.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932971AbcGERRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 13:17:46 -0400
In-Reply-To: <146772437424.21657.5653571141789810019.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 05 Jul 2016 14:12:54 +0100

> The main connection list is used for two independent purposes: primarily it
> is used to find connections to reap and secondarily it is used to list
> connections in procfs.
> 
> Split the procfs list out from the reap list.  This allows the reap list to
> be phased out in stages as the client conns and service conns acquire their
> own separate connection management strategies.
> 
> Whilst we're at it, use the address information stored in conn->proto when
> displaying through procfs rather than accessing the peer record.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Wouldn't it be better to just code the proc stuff to walk whatever
table the rest of the stack uses to hold all of the connections
as TCP et al. do?
