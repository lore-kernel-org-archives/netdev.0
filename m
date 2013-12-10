From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Mon, 09 Dec 2013 19:58:54 -0500 (EST)
Message-ID: <20131209.195854.223825767831436997.davem@davemloft.net>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab3LJA6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 19:58:55 -0500
In-Reply-To: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 6 Dec 2013 17:53:29 +0800

> Hi, Dave/Steffen
> 
> Current pktgen IPsec supports only transport/ESP combinnation,
> and it's buggy before I fixed transformed IP header/length issue
> a few days ago.
> 
> This patchset enables user to do almost any IPsec transformation,
> both transport/tunnel mode, and AH/ESP/IPcomp type.
> 
> Below configuration has been tested, and using Wireshark could decrypt
> out plain text in good formation without any checksum/auth errors:
> 
> Mode/TYPE	AH	ESP
> Transport	x	x
> Tunnel		x	x
> 
> ChangeLog
> v2:
>   Rebase patchset against newest net-next.
>   Patch1: Remove adding rebundant empty line spotted by Sergei.
>   Patch2: Use only one dst pointing into itself to save space.

I don't like how you've arranged this.

The existing mechanism might be used by someone, and in patch #1
you just remove it.

It's fixed, but so what?  It might useful for someone.

You must make your changes such that existing setups still
work, you can't just break things on people.
