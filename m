From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND] NET: Add the helper kernel_sock_shutdown()
Date: Mon, 12 Nov 2007 18:10:49 -0800 (PST)
Message-ID: <20071112.181049.231646376.davem@davemloft.net>
References: <1194898764.7465.65.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48752
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751785AbXKMCKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 21:10:50 -0500
In-Reply-To: <1194898764.7465.65.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Mon, 12 Nov 2007 15:19:24 -0500

> ...and fix a couple of bugs in the NBD, CIFS and OCFS2 socket handlers.
> 
> Looking at the sock->op->shutdown() handlers, it looks as if all of them
> take a SHUT_RD/SHUT_WR/SHUT_RDWR argument instead of the
> RCV_SHUTDOWN/SEND_SHUTDOWN arguments.
> Add a helper, and then define the SHUT_* enum to ensure that kernel users
> of shutdown() don't get confused.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Paul Clements <Paul.Clements@steeleye.com>
> Acked-by: Mark Fasheh <mark.fasheh@oracle.com>
> Cc: Steve French <sfrench@samba.org>
> Acked-by: David Howells <dhowells@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>

Applied, thanks Trond.
