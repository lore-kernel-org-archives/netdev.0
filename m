From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Modify bonding hash transmit policies to use the
 packet's source MAC address
Date: Sat, 24 Oct 2009 07:02:59 -0700 (PDT)
Message-ID: <20091024.070259.156043509.davem@davemloft.net>
References: <4AE1A37F.8010203@gmail.com>
	<20091023140845.GA24564@spaans.fox.local>
	<15644.1256314992@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: spaans@fox-it.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753779AbZJXOCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 10:02:36 -0400
In-Reply-To: <15644.1256314992@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 23 Oct 2009 09:23:12 -0700

> Jasper Spaans <spaans@fox-it.com> wrote:
> 
>>Modify bonding hash transmit policies to use the psource MAC address of
>>the packet instead of the MAC address configured for the bonding device.
>>
>>The old sitation conflicts with the documentation.
>>
>>Signed-off-by: Jasper Spaans <spaans@fox-it.com>
> 
> 	Looks good.
> 
> 	Dave, please apply.  This may be suitable for -stable, as it's
> pretty much a day one bug.

Applied, and queued up for stable, thanks everyone.
