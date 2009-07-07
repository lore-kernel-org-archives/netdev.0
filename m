From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: fix definition of 5272 version of
 FEC_X_DES_ACTIVE register
Date: Mon, 06 Jul 2009 18:27:04 -0700 (PDT)
Message-ID: <20090706.182704.192109619.davem@davemloft.net>
References: <200907070123.n671NY36005818@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerg@uclinux.org, s.hauer@pengutronix.de
To: gerg@snapgear.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49082
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754156AbZGGB05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:26:57 -0400
In-Reply-To: <200907070123.n671NY36005818@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@snapgear.com>
Date: Tue, 7 Jul 2009 11:23:34 +1000

> fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register
> 
> The ColdFire 5272 FEC driver has a different register address map
> than other users of the FEC driver. And its definition of the
> FEC_X_DES_ACTIVE register is incorrect, it should be 0x14.
> The fec interface cannot transmit data with the old value.
> 
> Signed-off-by: Greg Ungerer <gerg@uclinux.org>

This wasn't handled well at all.

You sent me what amounted to a cleanup patch to remove the
trailing ";" in these definitions first.  I can only put
that into net-next-2.6

Now you send me a real bug fix for one of these macro
values and it only applies on top of that ";" removal
patch.

That completely sucks.  Now I can't just apply this to
net-2.6 to get the bug fixed.

You should have sent just the bug fix, then waited a week
or so for the net-2.6 tree to get merged into the net-next-2.6
tree and then you could send the ";" cleanup cleanly on top
of that.

I can't apply this so I'm rejecting it in patchwork.
