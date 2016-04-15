From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] rxrpc: Don't permit use of connect() op and
 simplify sendmsg() op
Date: Thu, 14 Apr 2016 21:07:13 -0400 (EDT)
Message-ID: <20160414.210713.1128991767536792390.davem@davemloft.net>
References: <20160412150533.20637.23952.stgit@warthog.procyon.org.uk>
	<20160412150540.20637.31886.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbcDOBHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 21:07:16 -0400
In-Reply-To: <20160412150540.20637.31886.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 12 Apr 2016 16:05:41 +0100

> Simplify the RxRPC user interface and remove the use of connect() to direct
> client calls.  It is redundant given that sendmsg() can be given the target
> address and calls to multiple targets are permitted from a client socket
> and also from a service socket.

You can't just change completely the socket semantics for your
protocol like this, every single userland application is going to
break.

Sorry, there is no way I am applying changes like this.
