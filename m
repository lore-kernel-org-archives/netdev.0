From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 15:47:38 -0400 (EDT)
Message-ID: <20110519.154738.275060535891384598.davem@davemloft.net>
References: <4DD56E7A.3010901@neli.hopto.org>
	<20110519.153507.578609630787612821.davem@davemloft.net>
	<4DD571ED.8060400@neli.hopto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, netdev@vger.kernel.org
To: micha@neli.hopto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933670Ab1ESTrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:47:45 -0400
In-Reply-To: <4DD571ED.8060400@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha Nelissen <micha@neli.hopto.org>
Date: Thu, 19 May 2011 21:39:25 +0200

> David Miller wrote:
>> From: Micha Nelissen <micha@neli.hopto.org>
>> Date: Thu, 19 May 2011 21:24:42 +0200
>> 
>>> Even if link is "fake up" by driver and not actually up after 10 msecs,
>>> things will continue to work (eventually), after a second, just like now.
>> 
>> But this eats one of the CONF_SEND_RETRIES attempts, which is only 6.
> 
> Right. So an alternative could be to increase this to 7, or do you
> prefer leaving the 1 sec timeout untouched?

I'm not so sure at the moment.

Why don't you post your patch with the "bool" thing fixed and I'll
think about it?

Thanks.
