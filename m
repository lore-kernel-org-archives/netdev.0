From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RxRPC: Error handling for rxrpc_alloc_connection()
Date: Thu, 21 May 2009 15:22:10 -0700 (PDT)
Message-ID: <20090521.152210.96470496.davem@davemloft.net>
References: <20090521132027.12364.63780.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, error27@gmail.com
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755264AbZEUWWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:22:12 -0400
In-Reply-To: <20090521132027.12364.63780.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Thu, 21 May 2009 14:20:27 +0100

> From: Dan Carpenter <error27@gmail.com>
> 
> rxrpc_alloc_connection() doesn't return an error code on failure, it just
> returns NULL.  IS_ERR(NULL) is false.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied to net-2.6, thanks!
