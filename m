From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] Do not drop DNATed 6to4/6rd packets
Date: Sun, 15 Sep 2013 15:14:02 +0200
Message-ID: <20130915131401.GA18477@order.stressinduktion.org>
References: <1379154647-5781-1-git-send-email-catab@embedromix.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net
To: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58673 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756271Ab3IONOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 09:14:04 -0400
Content-Disposition: inline
In-Reply-To: <1379154647-5781-1-git-send-email-catab@embedromix.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 14, 2013 at 01:30:47PM +0300, Catalin(ux) M. BOIE wrote:
> From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
> 
> When a router is doing  DNAT for 6to4/6rd packets the latest anti-spoofing
> patch (218774dc) will drop them because the IPv6 address embedded
> does not match the IPv4 destination. This patch will allow them to
> pass by testing if we have an address that matches on 6to4/6rd interface.
> I have been hit by this problem using Fedora and IPV6TO4_IPV4ADDR.
> Also, log the dropped packets (with rate limit).
> 
> Signed-off-by: Catalin(ux) M. BOIE <catab@embedromix.ro>

Pretty neat idea, I think. Could you rebase the patch ontop of net or net-next
and have a look at the warnings when you feed your patch to
./scripts/checkpatch --strict?

Greetings,

  Hannes
