From: David Miller <davem@davemloft.net>
Subject: Re: network card with inline crypto engine?
Date: Tue, 19 Aug 2008 01:50:36 -0700 (PDT)
Message-ID: <20080819.015036.223405950.davem@davemloft.net>
References: <804fd2027cd558087a3db013b9ec80af@91.121.53.53>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jcd@tribudubois.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751562AbYHSIuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:50:37 -0400
In-Reply-To: <804fd2027cd558087a3db013b9ec80af@91.121.53.53>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Christophe DUBOIS <jcd@tribudubois.net>
Date: Tue, 19 Aug 2008 10:16:56 +0200

> Is there in the linux tree a "reference" implementation for a network card
> with inline crypto engine that would be used for IPSEC among other things.

Not really.

Once there was an attempt to support the crypto offload some
older 3com networking cards have, but that never went anywhere
and the hooks that were added by that code to the IPSEC stack
were never in a clean and usable state so never were merged.
