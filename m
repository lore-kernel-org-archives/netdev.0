From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: sysctl interface leaks 16 bytes of kernel memory
Date: Thu, 11 Oct 2012 15:13:44 -0400 (EDT)
Message-ID: <20121011.151344.618364814979945725.davem@davemloft.net>
References: <20121011162407.2590.40301.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667Ab2JKTNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 15:13:46 -0400
In-Reply-To: <20121011162407.2590.40301.stgit@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Thu, 11 Oct 2012 17:24:14 +0100

> From: Alan Cox <alan@linux.intel.com>
> 
> If the rc_dereference of tcp_fastopen_ctx ever fails then we copy 16 bytes
> of kernel stack into the proc result.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied and queued up for -stable.
