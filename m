From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] irtty-sir.c: Do not set_termios() on irtty_close()
Date: Mon, 17 Feb 2014 16:28:20 -0500 (EST)
Message-ID: <20140217.162820.1092957787354922201.davem@davemloft.net>
References: <52FC87B6.4070001@gannert.se>
	<5302750C.6080407@gannert.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tommie@gannert.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaBQV2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:28:25 -0500
In-Reply-To: <5302750C.6080407@gannert.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommie Gannert <tommie@gannert.se>
Date: Mon, 17 Feb 2014 20:46:04 +0000

> From: Tommie Gannert <tommie@gannert.se>
> 
> Issuing set_termios() from irtty_close() causes kernel Oops for
> unplugged usb-serial devices.
> 
> Since no other tty_ldisc calls set_termios() on close and no tty driver
> seem to check if tty->device_data is NULL or not on entry to set_termios(),
> the only solution I can come up with is to remove the irtty_stop_receiver()
> call, which only updates termios.
> 
> Signed-off-by: Tommie Gannert <tommie@gannert.se>

Applied, thank you.
