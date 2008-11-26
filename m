From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hp-plus uses eip_poll
Date: Tue, 25 Nov 2008 21:05:24 -0800 (PST)
Message-ID: <20081125.210524.248687025.davem@davemloft.net>
References: <20081125195400.dbb46066.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750718AbYKZFFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:05:24 -0500
In-Reply-To: <20081125195400.dbb46066.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 25 Nov 2008 19:54:00 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> hp-plus uses 8390p.c, so it should use eip_poll(), not ei_poll().
> 
> drivers/built-in.o: In function `hpp_probe1':
> hp-plus.c:(.init.text+0x9cbd): undefined reference to `ei_poll'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

I'll apply this to net-2.6

But can you take a look at what I just pushed out to
net-next-2.6 wrt. this driver and give me a hand untangling
things there?

Thanks a lot Randy!

