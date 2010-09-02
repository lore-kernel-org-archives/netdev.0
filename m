From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] wan: make driver strings const
Date: Wed, 01 Sep 2010 19:19:21 -0700 (PDT)
Message-ID: <20100901.191921.66727586.davem@davemloft.net>
References: <20100901181515.02c5abdc@nehalam>
	<20100901.182014.141246825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, andrew.hendry@gmail.com,
	elendil@planet.nl, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59354
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751762Ab0IBCTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 22:19:05 -0400
In-Reply-To: <20100901.182014.141246825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 01 Sep 2010 18:20:14 -0700 (PDT)

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 1 Sep 2010 18:15:15 -0700
> 
>> Change several wan drivers to make strings and other initialize
>> only parameters const.
>> 
>> Compile tested only.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Applied, thanks.

You may have "compile tested", but you certainly didn't watch out
for new warnings:

drivers/net/wan/cycx_drv.c: In function 'cycx_setup':
drivers/net/wan/cycx_drv.c:141:2: warning: passing argument 1 of 'get_option_index' discards qualifiers from pointer target type
drivers/net/wan/cycx_drv.c:76:12: note: expected 'long int *' but argument is of type 'const long int *'
drivers/net/wan/cycx_drv.c:151:2: warning: passing argument 1 of 'get_option_index' discards qualifiers from pointer target type
drivers/net/wan/cycx_drv.c:76:12: note: expected 'long int *' but argument is of type 'const long int *'

I've reverted your patch.
