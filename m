From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: split tcp_ecn sysctl knob to distinguish
 between IPv4 and IPv6
Date: Thu, 03 Jan 2013 05:13:27 -0800
Message-ID: <1357218807.21409.24399.camel@edumazet-glaptop>
References: <20130103000009.GG4464@order.stressinduktion.org>
	 <1357217260.21409.24224.camel@edumazet-glaptop>
	 <20130103125736.GI4464@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:50043 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab3ACNNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 08:13:30 -0500
Received: by mail-pb0-f50.google.com with SMTP id wz7so8521812pbc.9
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 05:13:29 -0800 (PST)
In-Reply-To: <20130103125736.GI4464@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-03 at 13:57 +0100, Hannes Frederic Sowa wrote:

> Currently not, but I will try. :)
> 
> Is the direction to split the sysctl ok? Or should it be a unified sysctl for
> ipv4/ipv6 and only be separate per namespace?
> 

I fixed some ECN glitches in IPv6 in the past, I am not sure we can
assume IPv6 gear is ECN bug free. In fact it might be the opposite.

So adding a per net sysctl would allow a better tuning for experiments,
and allow some applications to use a private netns and change their
sysctl.
