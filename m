From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: fix calculation of res_size for ioremap
Date: Thu, 07 May 2009 15:00:18 -0700 (PDT)
Message-ID: <20090507.150018.39533415.davem@davemloft.net>
References: <1241613956-7940-1-git-send-email-mludwig@ultratronik.de>
	<OF9818CA9E.B06011AE-ON802575AF.00354281-802575AF.00358C0A@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mludwig@ultratronik.de, netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752188AbZEGWAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 18:00:22 -0400
In-Reply-To: <OF9818CA9E.B06011AE-ON802575AF.00354281-802575AF.00358C0A@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Thu, 7 May 2009 10:45:05 +0100

> Matthias Ludwig <mludwig@ultratronik.de> wrote on 06/05/2009 13:45:56:
> 
>> fix size of remaped iomem, which is 1 byte to small
>> (e.g. mappes only 0xff bytes instead of 0x100)
> 
> *shrug* - I guess we should fix this for correctness but the highest
> register offset in the device is 0xb4 so this shouldn't cause any
> actual problems.
> 
>> Signed-off-by: Matthias Ludwig <mludwig@ultratronik.de>
> 
> Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied to net-next-2.6
