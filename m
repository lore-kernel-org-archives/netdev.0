From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix kfifo_alloc() error check
Date: Wed, 22 Nov 2006 20:35:00 -0800 (PST)
Message-ID: <20061122.203500.63996454.davem@davemloft.net>
References: <20061122183335.GA2985@APFDCB5C>
	<20061122110246.791beabd@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akinobu.mita@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:16622
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1755095AbWKWEe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 23:34:58 -0500
To: shemminger@osdl.org
In-Reply-To: <20061122110246.791beabd@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 22 Nov 2006 11:02:46 -0800

> On Thu, 23 Nov 2006 03:33:35 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 
> > The return value of kfifo_alloc() should be checked by IS_ERR().
> > 
> > Cc: Stephen Hemminger <shemminger@osdl.org>
> > Cc: David Miller <davem@davemloft.net>
> > Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
 ...
> Good thanks

Looks good to me too, applied, thanks.
