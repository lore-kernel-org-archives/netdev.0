From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: fix inconsistent prefix route handling
Date: Mon, 17 Feb 2014 14:05:57 +0100
Message-ID: <20140217130557.GC22833@order.stressinduktion.org>
References: <20140216165128.GF8634@order.stressinduktion.org> <5301AF26.7080102@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Steven Barth <cyrus@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60647 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbaBQNF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 08:05:58 -0500
Content-Disposition: inline
In-Reply-To: <5301AF26.7080102@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 07:41:42AM +0100, Steven Barth wrote:
> Hannes Frederic Sowa wrote:
> >This could too easily clean up valid on-link information if the address
> >just happens to be in the same subnet. Would (ifp-flags &
> >(IFA_F_PERMANENET|IFA_F_TEMPORARY) && !(...)) solve the problem, too?
> 
> No, that doesn't do the trick unfortunately. Seems that the 
> (non-permanent) address created by "ip" don't have IFA_F_TEMPORARY set.
> Any other good ideas?

We are talking about managed temp addresses, no? What ip command do you use?

Bye,

  Hannes
