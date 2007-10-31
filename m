From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Wed, 31 Oct 2007 08:50:41 +0000
Message-ID: <20071031085041.GA4362@infradead.org>
References: <20071030160401.296770000@chello.nl> <200710311426.33223.nickpiggin@yahoo.com.au> <20071030.213753.126064697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:54079 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbXJaIuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 04:50:46 -0400
Content-Disposition: inline
In-Reply-To: <20071030.213753.126064697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 09:37:53PM -0700, David Miller wrote:
> Don't be misled.  Swapping over NFS is just a scarecrow for the
> seemingly real impetus behind these changes which is network storage
> stuff like iSCSI.

So can we please do swap over network storage only first?  All these
VM bits look conceptually sane to me, while the changes to the swap
code to support nfs are real crackpipe material.   Then again doing
that part properly by adding address_space methods for swap I/O without
the abuse might be a really good idea, especially as the way we
do swapfiles on block-based filesystems is an horrible hack already.

So please get the VM bits for swap over network blockdevices in first,
and then we can look into a complete revamp of the swapfile support
that cleans up the current mess and adds support for nfs insted of
making the mess even worse.

