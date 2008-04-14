From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Mon, 14 Apr 2008 00:46:26 -0700 (PDT)
Message-ID: <20080414.004626.161082224.davem@davemloft.net>
References: <480262E9.4030500@trash.net>
	<480267C0.6020402@trash.net>
	<48026AAE.8040500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	protasnb@gmail.com, netdev@vger.kernel.org, andy@greyhouse.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34964
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbYDNHqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 03:46:25 -0400
In-Reply-To: <48026AAE.8040500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 13 Apr 2008 22:18:54 +0200

> [BRIDGE]: Fix crash in __ip_route_output_key with bridge netfilter
> 
> The bridge netfilter code attaches a fake dst_entry with a pointer to a
> fake net_device structure to skbs it passes up to IPv4 netfilter. This
> leads to crashes when the skb is passed to __ip_route_output_key when
> dereferencing the namespace pointer.
> 
> Since bridging can currently only operate in the init_net namespace,
> the easiest fix for now is to initialize the nd_net pointer of the
> fake net_device struct to &init_net.
> 
> Should fix bugzilla 10323: http://bugzilla.kernel.org/show_bug.cgi?id=10323
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Even though we don't have a test report back yet, I've applied this,
thanks Patrick.
