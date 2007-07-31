From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193
 addresses
Date: Mon, 30 Jul 2007 17:21:05 -0700 (PDT)
Message-ID: <20070730.172105.35015509.davem@davemloft.net>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
	<20070726.133452.78498553.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	sakkiped@starentnetworks.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761278AbXGaAVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 20:21:06 -0400
In-Reply-To: <20070726.133452.78498553.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 26 Jul 2007 13:34:52 -0500 (CDT)

> In article <18087.57717.495366.413571@zeus.sw.starentnetworks.com> (at Wed, 25 Jul 2007 19:49:09 -0400), Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com> says:
> 
> > ipv6_addr_type() doesn't check for 'Unique Local IPv6 Unicast
> > Addresses' (RFC4193) and returns IPV6_ADDR_RESERVED for that range.
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Ok, I've applied Dave's patch.

Dave, although it's customary and fine to use "+foo-list" email
addresses for mailing list subscriptions and discussions, I
ask that you don't add that cookie to your signoff lines in
patch submissions and I've removed it from your's in this patch.

Thanks a lot.
