From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND 3] IPv6: 6rd tunnel mode
Date: Wed, 07 Oct 2009 01:24:36 -0700 (PDT)
Message-ID: <20091007.012436.74941374.davem@davemloft.net>
References: <20090922220251.GA22874@lnxos.staff.proxad.net>
	<20090923184314.a2a2701d.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acassen@freebox.fr, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36037
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758787AbZJGIYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:24:41 -0400
In-Reply-To: <20090923184314.a2a2701d.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 23 Sep 2009 18:43:14 +0900

> Subject: [PATCH] ipv6 sit: 6rd (IPv6 Rapid Deployment) Support.
> 
> IPv6 Rapid Deployment (6rd; draft-ietf-softwire-ipv6-6rd) builds upon
> mechanisms of 6to4 (RFC3056) to enable a service provider to rapidly
> deploy IPv6 unicast service to IPv4 sites to which it provides
> customer premise equipment.  Like 6to4, it utilizes stateless IPv6 in
> IPv4 encapsulation in order to transit IPv4-only network
> infrastructure.  Unlike 6to4, a 6rd service provider uses an IPv6
> prefix of its own in place of the fixed 6to4 prefix.
> 
> With this option enabled, the SIT driver offers 6rd functionality by
> providing additional ioctl API to configure the IPv6 Prefix for in
> stead of static 2002::/16 for 6to4.
> 
> Original patch was done by Alexandre Cassen <acassen@freebox.fr>
> based on old Internet-Draft.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks everyone.
