From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Mon, 19 Nov 2007 22:15:31 -0800 (PST)
Message-ID: <20071119.221531.142096724.davem@davemloft.net>
References: <20071119152933.GA19126@one.firstfloor.org>
	<20071119.142313.63549156.davem@davemloft.net>
	<20071120002945.91fafb2b.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755073AbXKTGPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:15:31 -0500
In-Reply-To: <20071120002945.91fafb2b.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Fink <billfink@mindspring.com>
Date: Tue, 20 Nov 2007 00:29:45 -0500

> But the best approach seems to be just not to count
> it in the first place until tha application has actually received
> the packet, since as Herbert pointed out, that's what the RFC
> actually specifies for the meaning of the udpInDatagrams counter.

I agree and would be happy to apply such a patch :)
