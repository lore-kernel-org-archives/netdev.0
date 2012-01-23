From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] dsa: Add reporting of silicon revision for Marvell
 88E6123/88E6161/88E6165 switches.
Date: Mon, 23 Jan 2012 13:59:40 -0500 (EST)
Message-ID: <20120123.135940.341602114077968006.davem@davemloft.net>
References: <1327303254-28573-1-git-send-email-cphealy@gmail.com>
	<4F1D2CDA.9050107@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cphealy@gmail.com, ben@decadent.org.uk, buytenh@wantstofly.org,
	netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843Ab2AWS7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 13:59:55 -0500
In-Reply-To: <4F1D2CDA.9050107@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Mon, 23 Jan 2012 10:48:10 +0100

> On 01/23/12 08:20, Chris Healy wrote:
>> +		if ((ret&  0xfff0) == 0x1650)
>>   			return "Marvell 88E6165";
>>   	}
> 
> What about a switch/case here?

I don't think you can express "(ret&  0xfff0) == 0x1650)" using
a switch statement.

But BTW, the formatting of that expression needs to be cleaned up.
It should be "(ret & 0xfff0) == 0x1650)"
