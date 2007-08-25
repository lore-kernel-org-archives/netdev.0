From: David Miller <davem@davemloft.net>
Subject: Re: ppp dependency on slhc
Date: Fri, 24 Aug 2007 22:57:47 -0700 (PDT)
Message-ID: <20070824.225747.102456373.davem@davemloft.net>
References: <20070821013057.48e5af73.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48714
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757376AbXHYF5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 01:57:49 -0400
In-Reply-To: <20070821013057.48e5af73.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 21 Aug 2007 01:30:57 -0700

> ERROR: "slhc_init" [drivers/net/ppp_generic.ko] undefined!
> ERROR: "slhc_free" [drivers/net/ppp_generic.ko] undefined!
> ERROR: "slhc_uncompress" [drivers/net/ppp_generic.ko] undefined!
> ERROR: "slhc_compress" [drivers/net/ppp_generic.ko] undefined!
> ERROR: "slhc_toss" [drivers/net/ppp_generic.ko] undefined!
> ERROR: "slhc_remember" [drivers/net/ppp_generic.ko] undefined!
> 
> yet another reminder that select doesn't work ;)

Indeed :-)

However it is a good example of the kind of cases select was
made for, nobody should have to know about SLHC in order to
get PPP offered in the config.
