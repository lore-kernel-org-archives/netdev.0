From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9601: fix phy/eeprom write routine
Date: Mon, 03 May 2010 15:27:00 -0700 (PDT)
Message-ID: <20100503.152700.11978044.davem@davemloft.net>
References: <1272916886-8841-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.planes@free.fr, stable@kernel.org
To: jacmet@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59182
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758948Ab0ECW0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:26:53 -0400
In-Reply-To: <1272916886-8841-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Mon,  3 May 2010 22:01:26 +0200

> Use correct bit positions in DM_SHARED_CTRL register for writes.
> 
> Michael Planes recently encountered a 'KY-RS9600 USB-LAN converter', which
> came with a driver CD containing a Linux driver. This driver turns out to
> be a copy of dm9601.c with symbols renamed and my copyright stripped.
> That aside, it did contain 1 functional change in dm_write_shared_word(),
> and after checking the datasheet the original value was indeed wrong
> (read versus write bits).
> 
> On Michaels HW, this change bumps receive speed from ~30KB/s to ~900KB/s.
> On other devices the difference is less spectacular, but still significant
> (~30%).
> 
> Reported-by: Michael Planes <michael.planes@free.fr>
> CC: stable@kernel.org
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied, thanks!
