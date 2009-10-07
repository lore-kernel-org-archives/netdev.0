From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
 sockets, and for IPv4 multicast forwarding
Date: Wed, 07 Oct 2009 13:56:27 -0700 (PDT)
Message-ID: <20091007.135627.96995518.davem@davemloft.net>
References: <200910051646.34770.atis@mikrotik.com>
	<20091007.031957.197632672.davem@davemloft.net>
	<200910071559.56526.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com, zenczykowski@gmail.com
To: atis@mikrotik.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933651AbZJGU4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 16:56:31 -0400
In-Reply-To: <200910071559.56526.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atis Elsts <atis@mikrotik.com>
Date: Wed, 7 Oct 2009 15:59:56 +0300

> Here is the sk_mark part.

Applied, thanks.

> As for the ipmr.c code, I agree with your comment. Using mark from
> skb probably is wrong in case of tunnel interface (i.e. in the "if
> (vif->flags&VIFF_TUNNEL)" part of the patch), my mistake. I still
> think that the "else" part is correct, though, because using mark
> from skb there mirrors behaviour for unicast forwarding routing
> lookup in ip_route_input_slow(). The same applies to IPv6 code in
> ip6mr_forward2().

Ok submit just the else part and we'll have a look at it.

Thanks.
