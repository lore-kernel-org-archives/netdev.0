From: David Miller <davem@davemloft.net>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Fri, 05 Jan 2007 12:34:18 -0800 (PST)
Message-ID: <20070105.123418.50594534.davem@davemloft.net>
References: <E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
	<20070104.123333.91315611.davem@davemloft.net>
	<459EB627.5040606@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, dlstevens@us.ibm.com, jarkao2@o2.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52580
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750723AbXAEUeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 15:34:19 -0500
To: greearb@candelatech.com
In-Reply-To: <459EB627.5040606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 05 Jan 2007 12:33:43 -0800

> We were able to reproduce the problem twice on the un-patched 2.6.18.2 kernel in about
> 2 hours of our stress test yesterday.  I applied this patch (well, the
> ipv4 part..the ipv6 won't apply to 2.6.18.2), and it has run the stress
> test clean for a total of about 8 hours.
> 
> So, I do believe this was the problem we were hitting, and it seems fixed.

Thanks for all the testing Ben, much appreciated!
