From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v3 net-next 0/3] Add support for async socket operations
Date: Thu, 19 Mar 2015 19:51:05 +0000
Message-ID: <20150319195105.GS29656@ZenIV.linux.org.uk>
References: <20150319193118.11500.10463.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-aio@kvack.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ying.xue@windriver.com, bcrl@kvack.org,
	linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55780 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbCSTvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:51:14 -0400
Content-Disposition: inline
In-Reply-To: <20150319193118.11500.10463.stgit@tstruk-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 12:31:19PM -0700, Tadeusz Struk wrote:
> After the iocb parameter has been removed from sendmsg() and recvmsg() ops
> the socket layer, and the network stack no longer support async operations.
> This patch set adds support for asynchronous operations on sockets back.
> 
> Changes in v3:
> * As sugested by Al Viro instead of adding new functions aio_sendmsg
>   and aio_recvmsg, added a ptr to iocb into the kernel-side msghdr structure.
>   This way no change to aio.c is required.
> 
> Changes in v2:
> * removed redundant total_size param from aio_sendmsg and aio_recvmsg functions

I think I can live with that.  Christoph, do you have any objections to
that series?
