From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: avoid warnings when high-order page allocation
 fails
Date: Wed, 15 Apr 2009 03:40:07 -0700 (PDT)
Message-ID: <20090415.034007.10320617.davem@davemloft.net>
References: <49E5B864.203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751014AbZDOKkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:40:18 -0400
In-Reply-To: <49E5B864.203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 15 Apr 2009 12:35:16 +0200

> Latest tcpdump/libpcap triggers annoying messages because of high order page
> allocation failures (when lowmem exhausted or fragmented)
> 
> These allocation errors are correctly handled so could be silent.
...
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Looks fine to me, applied.
