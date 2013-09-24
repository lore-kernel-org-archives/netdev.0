From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v5] IPv6 NAT: Do not drop DNATed 6to4/6rd packets
Date: Tue, 24 Sep 2013 23:36:06 +0200
Message-ID: <20130924213606.GB4446@order.stressinduktion.org>
References: <1379963485.3575.53.camel@joe-AO722> <1379966659-28838-1-git-send-email-catab@embedromix.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, joe@perches.com
To: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48634 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645Ab3IXVgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 17:36:07 -0400
Content-Disposition: inline
In-Reply-To: <1379966659-28838-1-git-send-email-catab@embedromix.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 11:04:19PM +0300, Catalin(ux) M. BOIE wrote:
> When a router is doing  DNAT for 6to4/6rd packets the latest anti-spoofing
> patch (218774dc) will drop them because the IPv6 address embedded
> does not match the IPv4 destination. This patch will allow them to
> pass by testing if we have an address that matches on 6to4/6rd interface.
> I have been hit by this problem using Fedora and IPV6TO4_IPV4ADDR.
> Also, log the dropped packets (with rate limit).
> 
> Signed-off-by: Catalin(ux) M. BOIE <catab@embedromix.ro>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
