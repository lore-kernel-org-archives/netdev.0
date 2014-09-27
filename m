From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: remove memory copy for rx path
Date: Sat, 27 Sep 2014 18:56:00 -0400 (EDT)
Message-ID: <20140927.185600.1057301078747765304.davem@davemloft.net>
References: <20140926.170720.2230061639326332503.davem@davemloft.net>
	<057807be43ca4c79ad51ab07c668519d@BLUPR03MB373.namprd03.prod.outlook.com>
	<20140927113937.GA25265@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaI0W4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 18:56:02 -0400
In-Reply-To: <20140927113937.GA25265@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 27 Sep 2014 13:39:37 +0200

> fugang.duan@freescale.com <fugang.duan@freescale.com> :
>> From: David Miller <davem@davemloft.net> Sent: Saturday, September 27, 2014 5:07 AM
> [...]
>> >We call this rx_copybreak, and there are many drivers you can look at to
>> >see how this works.
>> >
>> >Thanks.
>> 
>> Great suggestion. I will change it for next version.
> 
> Be aware that copybreak module option should be considered legacy.
> 
> There is an ethtool api for it.

Right.
