From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RxRPC: Fix a potential NULL dereference
Date: Fri, 06 Feb 2009 21:51:01 -0800 (PST)
Message-ID: <20090206.215101.208464793.davem@davemloft.net>
References: <20090206115943.6126.95330.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, error27@gmail.com,
	linux-afs@lists.infradead.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36442
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752654AbZBGFvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 00:51:05 -0500
In-Reply-To: <20090206115943.6126.95330.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 06 Feb 2009 11:59:43 +0000

> Fix a potential NULL dereference bug during error handling in
> rxrpc_kernel_begin_call(), whereby rxrpc_put_transport() may be handed a NULL
> pointer.
> 
> This was found with a code checker (http://repo.or.cz/w/smatch.git/).
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks David.
