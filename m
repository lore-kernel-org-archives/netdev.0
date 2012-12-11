From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event via
 rtnetlink
Date: Tue, 11 Dec 2012 18:40:13 +0000
Message-ID: <20121211184013.GD27746@casper.infradead.org>
References: <50BE56D3.2030704@6wind.com>
 <50BF29DA.7020903@6wind.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com>
 <20121205.125453.1457654258131828976.davem@davemloft.net>
 <50C05AC2.1050504@6wind.com>
 <20121206174905.GC16122@casper.infradead.org>
 <50C74B5D.9050708@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35761 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317Ab2LKSkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:40:20 -0500
Content-Disposition: inline
In-Reply-To: <50C74B5D.9050708@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/12 at 04:03pm, Nicolas Dichtel wrote:
> In fact, it seems not so easy because most users of nlmsg_new() calculate
> the exact needed length, thus if we add an unpredicted attribute,
> the message will be too small.

True, we would either need to fix the calculations by accounting
for an additional 4 bytes for each 64bit arg or just reserve an
additional fixed amount for padding per message in nlmsg_new().
