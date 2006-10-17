From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/13] [IPV6] Make sure error handling is done when
 calling ip6_route_output().
Date: Mon, 16 Oct 2006 22:10:21 -0700 (PDT)
Message-ID: <20061016.221021.131916336.davem@davemloft.net>
References: <45341DF8.90104@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, kim.nordlund@nokia.com,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:214
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423096AbWJQFKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:10:20 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <45341DF8.90104@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 17 Oct 2006 03:04:08 +0300

> As ip6_route_output() never returns NULL, error checking must be done by
> looking at dst->error in stead of comparing dst against NULL.
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Good catch, patch applied.

Thanks a lot.
