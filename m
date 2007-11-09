From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NET: Add the helper kernel_sock_shutdown()
Date: Fri, 09 Nov 2007 01:44:14 +0000
Message-ID: <18472.1194572654@redhat.com>
References: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	Paul Clements <Paul.Clements@steeleye.com>,
	Mark Fasheh <mark.fasheh@oracle.com>,
	Steve French <sfrench@samba.org>,
	David S Miller <davem@davemloft.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59122 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752991AbXKIBpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 20:45:16 -0500
In-Reply-To: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> Looking at the sock->op->shutdown() handlers, it looks as if all of them
> take a SHUT_RD/SHUT_WR/SHUT_RDWR argument instead of the
> RCV_SHUTDOWN/SEND_SHUTDOWN arguments.
> Add a helper, and then define the SHUT_* enum to ensure that kernel users
> of shutdown() don't get confused.

Acked-by: David Howells <dhowells@redhat.com>
