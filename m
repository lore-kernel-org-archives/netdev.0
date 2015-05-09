From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: avoid integer overflow in start_xmit
Date: Sat, 09 May 2015 16:46:35 -0400 (EDT)
Message-ID: <20150509.164635.1141216772229266057.davem@davemloft.net>
References: <1430917780-12431-1-git-send-email-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.de, netdev@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbbEIUqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:46:36 -0400
In-Reply-To: <1430917780-12431-1-git-send-email-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Wed,  6 May 2015 15:09:40 +0200

> transfer_buffer_length is of type u32. It's therefore wrong to assign it
> to a signed integer. This patch avoids the overflow.
> 
> It's worth noting that entry->length here is a long; perhaps it would be
> beneficial at somepoint to change this to be unsigned as well, if
> nothing else relies on its signedness for error conditions or the like.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Applied, thanks.
