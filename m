From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mkiss: fix scribble on freed memory
Date: Wed, 06 Jan 2016 15:08:18 -0500 (EST)
Message-ID: <20160106.150818.1539288359464258183.davem@davemloft.net>
References: <20160106145449.28695.13562.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@vger.kernel.org
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbcAFUIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:08:19 -0500
In-Reply-To: <20160106145449.28695.13562.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan <gnomes@lxorguk.ukuu.org.uk>
Date: Wed, 06 Jan 2016 14:55:02 +0000

> commit d79f16c046086f4fe0d42184a458e187464eb83e fixed a user triggerable
> scribble on free memory but added a new one which allows the user to
> scribble even more and user controlled data into freed space.
> 
> As with 6pack we need to halt the queue before we free the buffers, because
> the transmit logic is not protected by the semaphore.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied and queued up for -stable, thanks Alan.
