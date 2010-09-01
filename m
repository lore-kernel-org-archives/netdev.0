From: David Miller <davem@davemloft.net>
Subject: Re: ERR_PTR pattern in phylib
Date: Wed, 01 Sep 2010 08:27:29 -0700 (PDT)
Message-ID: <20100901.082729.135524471.davem@davemloft.net>
References: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755783Ab0IAP1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 11:27:12 -0400
In-Reply-To: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Wed, 1 Sep 2010 08:42:49 -0600

> It seems to me that phylib is one of the cases where the users (the
> network drivers) don't actually care about the specific error code
> when calling phylib functions.  The drivers only seem to care whether
> or not the function failed, and if it did then bail out.  I've also
> noticed that using the "if (!ptr)" test on phylib return values is a
> common error for driver writers.
> 
> In the interest of making driver code easier to write and review,
> would you be opposed to a set of patches to remove the ERR_PTR()
> pattern from phylib and its users?

I'm opposed to it because it means that if code actually does
care about the error code it will no longer be able to obtain
it.

Please don't make this change, thanks.
