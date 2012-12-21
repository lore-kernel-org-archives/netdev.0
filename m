From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] IP_MAX_MTU value
Date: Fri, 21 Dec 2012 10:54:05 -0800
Message-ID: <1356116045.21834.7751.camel@edumazet-glaptop>
References: <1356072468.21834.4805.camel@edumazet-glaptop>
	 <50D4A84D.1010402@hp.com> <1356114879.21834.7709.camel@edumazet-glaptop>
	 <50D4AF72.2020101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:61489 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab2LUSyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:54:07 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so2213760dak.5
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 10:54:07 -0800 (PST)
In-Reply-To: <50D4AF72.2020101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 10:50 -0800, Rick Jones wrote:
> On 12/21/2012 10:34 AM, Eric Dumazet wrote:
> > On Fri, 2012-12-21 at 10:19 -0800, Rick Jones wrote:
> >
> >> If you go beyond the protocol limit of an IPv4 datagram, won't it be
> >> necessary to  start being a bit more conditional on IPv4 vs IPv6?
> >>
> >
> > This IP_MAX_MTU is really an IPv4 thing (static to net/ipv4/route.c)
> 
> OK. Doesn't this:
> 
>          if (mtu > IP_MAX_MTU)
>                  mtu = IP_MAX_MTU;
> 
> mean it should be OK to go to 0xFFFF but not 0x10000?  Since 65535 is 
> the limit of an IPv4 datagram and so I would think would be the maximum 
> MTU for an IPv4 interface.

Sure, I meant 0xFFFF and it is the value I used in my tests.

65536 is the current MTU of loopback device, and this can be used by
other protocols.
