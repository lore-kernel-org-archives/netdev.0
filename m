From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sat, 21 Jul 2007 20:54:25 -0700 (PDT)
Message-ID: <20070721.205425.61337743.davem@davemloft.net>
References: <1185059423.6344.53.camel@localhost.localdomain>
	<20070721.185905.18310463.davem@davemloft.net>
	<1185071972.6344.61.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754377AbXGVDy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 23:54:26 -0400
In-Reply-To: <1185071972.6344.61.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sun, 22 Jul 2007 12:39:32 +1000

> But if netdev -> driver_private can be optimized, so can driver_private
> -> netdev.  We just don't have a wrapper for it.  netdev_of() perhaps?
> 
> (If it can't be implemented by ptr arith, we have to do some allocation
> tricks to hide the dev ptr before driver_private, but it's still
> implementable).
> 
> Perhaps we should do this anyway: it's another "every driver wants it"
> kind of deal AFAICT...

Color me convinced :-)

Ok, I'll put the napi_struct info the driver private and respin
the patch.
