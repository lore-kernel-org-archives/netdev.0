From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ep93xx-eth: check for zero MAC address on probe,
 not on device open
Date: Sun, 29 Nov 2009 23:50:43 -0800 (PST)
Message-ID: <20091129.235043.101670708.davem@davemloft.net>
References: <200911290057.02109.florian@openwrt.org>
	<20091129121158.GV20214@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39060
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750956AbZK3Hui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 02:50:38 -0500
In-Reply-To: <20091129121158.GV20214@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Sun, 29 Nov 2009 13:11:58 +0100

> On Sun, Nov 29, 2009 at 12:57:00AM +0100, Florian Fainelli wrote:
> 
>> If we happen to have registered the driver without passing
>> a MAC address, we will print a zero MAC address and register
>> the interface with this invalid address, this is confusin. This
>> patch moves the checking of a valid ethernet address and the
>> generation of a random one down from the open function to
>> the probe function.
>> 
>> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> 
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Applied, thanks.
