From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NET: Add the helper kernel_sock_shutdown()
Date: Mon, 12 Nov 2007 08:33:03 -0500
Message-ID: <1194874383.7465.8.camel@heimdal.trondhjem.org>
References: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
	 <4145.1194870138@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Clements <Paul.Clements@steeleye.com>,
	Mark Fasheh <mark.fasheh@oracle.com>,
	Steve French <sfrench@samba.org>,
	David S Miller <davem@davemloft.net>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46553 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758677AbXKLNdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 08:33:38 -0500
In-Reply-To: <4145.1194870138@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-11-12 at 12:22 +0000, David Howells wrote:
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > take a SHUT_RD/SHUT_WR/SHUT_RDWR argument instead of the
> 
> Hmmm...  Why SHUT_*?  Why not SHUTDOWN_*?

SHUT_RD/SHUT_WR/SHUT_RDWR are the traditional names for these constants
(see 'man 3 shutdown') and so should be easier to remember. I didn't
however feel comfortable naming the function kernel_shutdown() or
shutdown(), since those have other connotations, hence
kernel_sock_shutdown().

