From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ucc_geth: separate out rx/tx ring alloc and
 free operations
Date: Sun, 04 Mar 2012 20:54:09 -0500 (EST)
Message-ID: <20120304.205409.156102112320808082.davem@davemloft.net>
References: <1330346189-25155-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246Ab2CEB4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:56:19 -0500
In-Reply-To: <1330346189-25155-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 27 Feb 2012 07:36:29 -0500

> Factor out the the existing allocation and free operations
> so that they can be used individually.
> 
> This is to improve code readability, and also to prepare for
> possible future changes like better error recovery and more
> dynamic configuration (e.g on-the-fly resizing of the rings).
> 
> This change represents a straight up relocation of the existing
> code into separate routines without changing any of the contained
> code itself.  Local variables are relocated as necessary.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
