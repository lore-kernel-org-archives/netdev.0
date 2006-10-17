From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/13] [RFC] [IPV6] Move source address selection into
 route lookup.
Date: Mon, 16 Oct 2006 22:22:23 -0700 (PDT)
Message-ID: <20061016.222223.26532234.davem@davemloft.net>
References: <4534201D.7070002@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61146
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423085AbWJQFWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:22:22 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <4534201D.7070002@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 17 Oct 2006 03:13:17 +0300

> This patch moves the normal source address selection from
> ip6_dst_lookup() into ip6_pol_route_output(), but shouldn't
> change the routing or source address selection behavior in
> any way.
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Although this conversion is very clean and the next patch
is very logic, I'm going to hold on all patches from 7 onward
so there is some time for some discussion of the RFC'ness
of them :-)

Thanks.
