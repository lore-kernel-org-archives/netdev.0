From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] route: Fix prohibit and blackhole routing decision
Date: Wed, 18 Oct 2006 20:47:10 -0700 (PDT)
Message-ID: <20061018.204710.84974088.davem@davemloft.net>
References: <20061018100619.GR12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18063
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423248AbWJSDrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:47:01 -0400
To: tgraf@suug.ch
In-Reply-To: <20061018100619.GR12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 18 Oct 2006 12:06:19 +0200

> Lookups resolving to ip6_blk_hole_entry must result in silently
> discarding the packets whereas an ip6_pkt_prohibit_entry is
> supposed to cause an ICMPV6_ADM_PROHIBITED message to be sent.
> 
> Thanks to Kim Nordlund <kim.nordlund@nokia.com> for noticing
> this bug.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks good Thomas, applied.

Thanks a lot.
