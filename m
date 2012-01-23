From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] dsa: Add reporting of silicon revision for Marvell
 88E6123/88E6161/88E6165 switches.
Date: Mon, 23 Jan 2012 14:46:30 -0500 (EST)
Message-ID: <20120123.144630.654662337465759134.davem@davemloft.net>
References: <4F1D2CDA.9050107@openwrt.org>
	<20120123.135940.341602114077968006.davem@davemloft.net>
	<1327347332.2438.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, cphealy@gmail.com, ben@decadent.org.uk,
	buytenh@wantstofly.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2AWTqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 14:46:49 -0500
In-Reply-To: <1327347332.2438.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 Jan 2012 19:35:32 +0000

> On Mon, 2012-01-23 at 13:59 -0500, David Miller wrote:
>> From: Florian Fainelli <florian@openwrt.org>
>> Date: Mon, 23 Jan 2012 10:48:10 +0100
>> 
>> > On 01/23/12 08:20, Chris Healy wrote:
>> >> +		if ((ret&  0xfff0) == 0x1650)
>> >>   			return "Marvell 88E6165";
>> >>   	}
>> > 
>> > What about a switch/case here?
>> 
>> I don't think you can express "(ret&  0xfff0) == 0x1650)" using
>> a switch statement.
>> 
>> But BTW, the formatting of that expression needs to be cleaned up.
>> It should be "(ret & 0xfff0) == 0x1650)"
> 
> Florian's mailer has mangled the quoted text; the original patch had
> correct spacing.

Thanks for pointing that out, then the patch is fine, applied.
