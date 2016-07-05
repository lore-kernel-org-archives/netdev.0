From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/24] rxrpc: Provide more refcount helper
 functions
Date: Tue, 05 Jul 2016 10:16:36 -0700 (PDT)
Message-ID: <20160705.101636.1426176903162735420.davem@davemloft.net>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
	<146772436726.21657.7089071379028604342.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278AbcGERQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 13:16:39 -0400
In-Reply-To: <146772436726.21657.7089071379028604342.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 05 Jul 2016 14:12:47 +0100

> Provide refcount helper functions for connections so that the code doesn't
> touch conn->usage directly.
> 
> Also provide queueing helper functions so that the queueing of local and
> connection objects can be fixed later.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

I don't see anything in this patch dealing with refcount helper functions.
