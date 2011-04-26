From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 4/4] xfrm: Fix integer underrun on zero sized
 replay windows
Date: Tue, 26 Apr 2011 12:48:03 -0700 (PDT)
Message-ID: <20110426.124803.183062337.davem@davemloft.net>
References: <20110426053923.GF5495@secunet.com>
	<20110426054232.GI5495@secunet.com>
	<20110426105840.GJ5495@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756666Ab1DZTsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:48:36 -0400
In-Reply-To: <20110426105840.GJ5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 26 Apr 2011 12:58:40 +0200

> On Tue, Apr 26, 2011 at 07:42:32AM +0200, Steffen Klassert wrote:
>> The check if the replay window is contained within one subspace or
>> spans over two subspaces causes an unwanted integer underrun on
>> zero sized replay windows when we subtract minus one. We fix this by
>> changeing this check to avoid the subtraction.
>> 
> 
> Don't apply this one, it does not fix the issue completely.
> I'll send a better one, sorry.

Ok.
