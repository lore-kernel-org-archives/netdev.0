From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [RFC] IP_MAX_MTU value
Date: Fri, 21 Dec 2012 10:34:39 -0800
Message-ID: <1356114879.21834.7709.camel@edumazet-glaptop>
References: <1356072468.21834.4805.camel@edumazet-glaptop>
	 <50D4A84D.1010402@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:54855 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab2LUSel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:34:41 -0500
Received: by mail-da0-f53.google.com with SMTP id x6so2210472dac.40
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 10:34:41 -0800 (PST)
In-Reply-To: <50D4A84D.1010402@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 10:19 -0800, Rick Jones wrote:

> If you go beyond the protocol limit of an IPv4 datagram, won't it be 
> necessary to  start being a bit more conditional on IPv4 vs IPv6?
> 

This IP_MAX_MTU is really an IPv4 thing (static to net/ipv4/route.c)


> 
> 99 times out of 10 I will assert that faster is better, but do we need 
> another 50% for UDP over loopback with that large a message size?

Well, I only didnt understand why sending 65507 UDP messages had to use
fragments. I didnt care of performance at this point, only tried to have
an reasonable explanation.

It turns out its a strange limitation.
