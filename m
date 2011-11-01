From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make the tcp and udp file_operations for the
 /proc stuff const
Date: Tue, 01 Nov 2011 17:56:33 -0400 (EDT)
Message-ID: <20111101.175633.1920208937281416034.davem@davemloft.net>
References: <20111030094630.47e247ae@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588Ab1KAV5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 17:57:41 -0400
In-Reply-To: <20111030094630.47e247ae@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Sun, 30 Oct 2011 09:46:30 -0700

> the tcp and udp code creates a set of struct file_operations at runtime
> while it can also be done at compile time, with the added benefit of then
> having these file operations be const.
> 
> the trickiest part was to get the "THIS_MODULE" reference right; the naive
> method of declaring a struct in the place of registration would not work
> for this reason.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

I have no problem with this, applied, thanks.
