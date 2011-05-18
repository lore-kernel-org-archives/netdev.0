From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Wed, 18 May 2011 18:14:27 -0400 (EDT)
Message-ID: <20110518.181427.1228926976939865196.davem@davemloft.net>
References: <4DD36803.1020001@neli.hopto.org>
	<20110518.023725.441358922110721042.davem@davemloft.net>
	<4DD36E54.9040706@neli.hopto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: micha@neli.hopto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab1ERWOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:14:32 -0400
In-Reply-To: <4DD36E54.9040706@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha Nelissen <micha@neli.hopto.org>
Date: Wed, 18 May 2011 08:59:32 +0200

> Op 2011-05-18 8:37, David Miller schreef:
>> From: Micha Nelissen<micha@neli.hopto.org>
>> Date: Wed, 18 May 2011 08:32:35 +0200
>>
>>> I'm confused. Against which tree/commit do you want it then?
>>
>> Linus's current tree would be fine as would:
>>
>> 	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> 
> Ok I see, thanks. The patch should apply just fine to your tree, there
> is only a spelling change since 2.6.38 which does not conflict.

Please fix ic_is_init_dev() to return a proper boolean "false" instead
of "0" when IFF_LOOPBACK is set.
