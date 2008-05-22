From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from
	lib/hexdump.c instead
Date: Wed, 21 May 2008 17:37:44 -0700
Message-ID: <1211416664.6908.11.camel@brick>
References: <1211323212.5915.220.camel@brick>
	 <20080520.154551.54365414.davem@davemloft.net>
	 <91b13c310805201927k4fccf8dcwa3fabe61777b2eda@mail.gmail.com>
	 <20080521.173521.265981118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: crquan@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.190]:5255 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764628AbYEVAhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 20:37:47 -0400
Received: by rn-out-0910.google.com with SMTP id k40so499066rnd.17
        for <netdev@vger.kernel.org>; Wed, 21 May 2008 17:37:46 -0700 (PDT)
In-Reply-To: <20080521.173521.265981118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-05-21 at 17:35 -0700, David Miller wrote:
> From: "rae l" <crquan@gmail.com>
> Date: Wed, 21 May 2008 10:27:41 +0800
> 
> > net/ipv4/arp.c: Use common hex_asc helpers
> > 
> > Here the local hexbuf is a duplicate of global const char hex_asc from
> > lib/hexdump.c, except the hex letters' cases:
> > 
> > 	const char hexbuf[] = "0123456789ABCDEF";
> > 
> > 	const char hex_asc[] = "0123456789abcdef";
> > 
> > and here to print HW addresses, the hex cases are not significant.
> > 
> > Thanks to Harvey Harrison to introduce the hex_asc_hi/hex_asc_lo helpers.
> > 
> > Signed-off-by: Denis Cheng <crquan@gmail.com>
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> Applied, thanks.
> 
> Harvey I know you posted a nearly identical patch, I had
> to choose one and he did credit you with the idea for the
> updated patch, so I hope this is OK.

His had the better changelog, I just sent mine to make my point clear
what the patch could look like.

No problems here.

Harvey

