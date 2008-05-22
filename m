From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from
 lib/hexdump.c instead
Date: Wed, 21 May 2008 17:35:21 -0700 (PDT)
Message-ID: <20080521.173521.265981118.davem@davemloft.net>
References: <1211323212.5915.220.camel@brick>
	<20080520.154551.54365414.davem@davemloft.net>
	<91b13c310805201927k4fccf8dcwa3fabe61777b2eda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933081AbYEVAf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 20:35:28 -0400
In-Reply-To: <91b13c310805201927k4fccf8dcwa3fabe61777b2eda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "rae l" <crquan@gmail.com>
Date: Wed, 21 May 2008 10:27:41 +0800

> net/ipv4/arp.c: Use common hex_asc helpers
> 
> Here the local hexbuf is a duplicate of global const char hex_asc from
> lib/hexdump.c, except the hex letters' cases:
> 
> 	const char hexbuf[] = "0123456789ABCDEF";
> 
> 	const char hex_asc[] = "0123456789abcdef";
> 
> and here to print HW addresses, the hex cases are not significant.
> 
> Thanks to Harvey Harrison to introduce the hex_asc_hi/hex_asc_lo helpers.
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks.

Harvey I know you posted a nearly identical patch, I had
to choose one and he did credit you with the idea for the
updated patch, so I hope this is OK.

Thanks.
