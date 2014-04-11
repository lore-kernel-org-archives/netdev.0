From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Does IPv6 support Jumbograms ?
Date: Thu, 10 Apr 2014 17:40:24 -0700
Message-ID: <1397176824.16584.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410235459.GK27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:52963 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaDKAk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 20:40:26 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so4661735pbc.27
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 17:40:25 -0700 (PDT)
In-Reply-To: <20140410235459.GK27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-04-11 at 01:54 +0200, Hannes Frederic Sowa wrote:

> > #define IP6_MAX_MTU (65535 + 40)
> 
>                              ^ minus
> 
> I think we should do that. Otherwise we would have to start supporting
> jumbograms in the output path generally.

Why 'minus' ?

hdr->payload_len = htons(seg_len);

seg_len doesn't include the IPv6 header.

So it seems we can use up to 65575 for the device mtu ?

Anyway I am testing the patch ;)
