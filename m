From: David Miller <davem@davemloft.net>
Subject: Re: PIM-SM namespace changes
Date: Sun, 14 Jun 2009 03:17:16 -0700 (PDT)
Message-ID: <20090614.031716.53296931.davem@davemloft.net>
References: <20090518.222429.135907168.davem@davemloft.net>
	<20090520004344.GA10143@boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54924
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752951AbZFNKRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 06:17:14 -0400
In-Reply-To: <20090520004344.GA10143@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Goff <thomas.goff@boeing.com>
Date: Tue, 19 May 2009 17:43:44 -0700

> For protocol registration I see three basic approaches for using PIM
> with namespaces:
> 
>   - unconditionally add PIM when multicast routing is initialized
>     (maybe only ifdef CONFIG_NET_NS, otherwise preserve the current
>     behavior)
> 
>   - keep a count of the number of namespaces that have enabled PIM and
>     add/delete PIM when transitioning from/to zero
> 
>   - make all or some protocol registration per network namespace
> 
> There are obviously tradeoffs and I would appreciate any
> comments/suggestions on alternatives that allow namespace use of
> dynamically enabled protocols.

Ok, I'm willing to accept your current approach for now, let's
see what falls out of this.  Patch applied, thanks.

Doing the enabling per-namespace is complexity for an unknown
gain.  I don't even know what the benefit could be for how we
behaved previously.

Anyone know?
