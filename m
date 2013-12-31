From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce hardened ip_no_pmtu_disc mode
Date: Tue, 31 Dec 2013 00:37:11 -0500 (EST)
Message-ID: <20131231.003711.245680762305512090.davem@davemloft.net>
References: <20131221001054.GD14073@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab3LaFhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 00:37:14 -0500
In-Reply-To: <20131221001054.GD14073@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 21 Dec 2013 01:10:54 +0100

> This new ip_no_pmtu_disc mode only allowes fragmentation-needed errors
> to be honored by protocols which do more stringent validation on the
> ICMP's packet payload. This knob is useful for people who e.g. want to
> run an unmodified DNS server in a namespace where they need to use pmtu
> for TCP connections (as they are used for zone transfers or fallback
> for requests) but don't want to use possibly spoofed UDP pmtu information.
> 
> Currently the whitelisted protocols are TCP, SCTP and DCCP as they check
> if the returned packet is in the window or if the association is valid.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I think this is going to have the same problem as the forwarding
sysctl, someone is going to convince some distribution to turn this
thing to the new "3" hardened mode by default.

I'm not applying this... for now, sorry.
