From: Mark Fasheh <mark.fasheh@oracle.com>
Subject: Re: [PATCH] NET: Add the helper kernel_sock_shutdown()
Date: Sun, 11 Nov 2007 10:03:41 -0800
Message-ID: <20071111180341.GP28607@ca-server1.us.oracle.com>
References: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
Reply-To: Mark Fasheh <mark.fasheh@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Paul Clements <Paul.Clements@steeleye.com>,
	Steve French <sfrench@samba.org>,
	David Howells <dhowells@redhat.com>,
	David S Miller <davem@davemloft.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56029 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374AbXKKSGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 13:06:34 -0500
Content-Disposition: inline
In-Reply-To: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 07:01:36PM -0500, Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> ...and fix a couple of bugs in the NBD, CIFS and OCFS2 socket handlers.
> 
> Looking at the sock->op->shutdown() handlers, it looks as if all of them
> take a SHUT_RD/SHUT_WR/SHUT_RDWR argument instead of the
> RCV_SHUTDOWN/SEND_SHUTDOWN arguments.
> Add a helper, and then define the SHUT_* enum to ensure that kernel users
> of shutdown() don't get confused.

That looks pretty good - any objection to naming the enum and using that
name in the prototype for kernel_sock_shutdown() so it's even more obvious
what type of shutdown argument this expects?
	--Mark

--
Mark Fasheh
Senior Software Developer, Oracle
mark.fasheh@oracle.com
