From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: mac802154: comparision issue of type cast,
 finding by EXTRA_CFLAGS=-W
Date: Thu, 25 Apr 2013 04:10:44 -0400 (EDT)
Message-ID: <20130425.041044.768895561908042668.davem@davemloft.net>
References: <5175DFBC.7040000@asianux.com>
	<5175F7F7.7000703@asianux.com>
	<51766F74.2090007@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755873Ab3DYIKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:10:46 -0400
In-Reply-To: <51766F74.2090007@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Tue, 23 Apr 2013 19:24:36 +0800

> 
> Need change ~(u8)0 to 0xff, or in mac802154_wpan_xmit(), "u8 chan"
> will never == MAC802154_CHAN_NONE.
> 
> The related warning:
>   net/mac802154/wpan.c:325:2: warning: comparison is always false
>   due to limited range of data type [-Wtype-limits]
> 
> The related unit test:
>   cc -Wall -O2 -o test test.c
>   ./test
>   will output 'different'
> 
>   (after use '0xff' instead of '~(u8)0', it will output 'equal')
 ...
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

This change belong in the 'net' tree, but your patch won't apply
cleanly there as this part of the header file looks slightly
different there.

Please respin your patch against 'net' and resubmit, thank you.
