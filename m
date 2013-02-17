From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 1/4] ipv6: introduce new type ipv6_addr_props to hold ipv6 address type and scope
Date: Sun, 17 Feb 2013 04:01:30 +0100
Message-ID: <20130217030130.GA28970@order.stressinduktion.org>
References: <20130216191008.GA23272@order.stressinduktion.org> <512013B8.3000608@linux-ipv6.org> <512016E8.30305@linux-ipv6.org> <20130217014718.GA28547@order.stressinduktion.org> <512045EA.9090309@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, brian.haley@hp.com
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39773 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745Ab3BQDBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 22:01:31 -0500
Content-Disposition: inline
In-Reply-To: <512045EA.9090309@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2013 at 11:52:26AM +0900, YOSHIFUJI Hideaki wrote:
> > Sorry, I am a bit confused. The missing '& IPV6_ADDR_SCOPE_MASK' is clearly a
> > bug. I implied a bitmask for the IPV6_ADDR_SCOPE_* macros. But I don't
> > understand to what you do refer in your second mail.
> > 
> 
> No, return __ipv6_addr_type(addr).type & IPV6_ADDR_SCOPE_MASK, see?

Got it, thanks.

> You have changed too many things in a single patch.
> Please do not try to change function arguments, and so on
> e.g. if original takes int by __ipv6_addr_type() value, please leave
> it semantics as is.
> 
> I think you can concentrate on your original work for multicast/scoping
> issues first.

Ok, will do.

Thanks,

  Hannes
