From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from
 lib/hexdump.c instead
Date: Tue, 20 May 2008 15:45:51 -0700 (PDT)
Message-ID: <20080520.154551.54365414.davem@davemloft.net>
References: <1211135864-8235-1-git-send-email-crquan@gmail.com>
	<20080520.153611.204837174.davem@davemloft.net>
	<1211323212.5915.220.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: crquan@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935729AbYETWp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 18:45:56 -0400
In-Reply-To: <1211323212.5915.220.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Tue, 20 May 2008 15:40:12 -0700

> On Tue, 2008-05-20 at 15:36 -0700, David Miller wrote:
> > From: Denis Cheng <crquan@gmail.com>
> > Date: Mon, 19 May 2008 02:37:44 +0800
> > 
> > > Here the local hexbuf is a duplicate of global const char hex_asc from
> > > lib/hexdump.c, except the hex letters' cases:
> > > 
> > > const char hexbuf[] = "0123456789ABCDEF";
> > > 
> > > const char hex_asc[] = "0123456789abcdef";
> > > 
> > > and here to print HW addresses, the hex cases are not significant.
> > > 
> > > Signed-off-by: Denis Cheng <crquan@gmail.com>
> > 
> > Applied, thanks.
> 
> You may want to use the hex_asc_hi, hex_asc_lo helpers to do the
> mask/shifts for you.

Good idea, I'll revert, Denis can you generate a new patch?

Thanks.
