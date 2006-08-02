From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/23] [PATCH] [XFRM] STATE: Add source address list.
Date: Tue, 01 Aug 2006 19:03:42 -0700 (PDT)
Message-ID: <20060801.190342.17865381.davem@davemloft.net>
References: <11541654121350-git-send-email-nakam@linux-ipv6.org>
	<20060801.165728.18308673.davem@davemloft.net>
	<44D0031B.8050509@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37824
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751007AbWHBCDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 22:03:47 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44D0031B.8050509@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Wed, 02 Aug 2006 10:42:51 +0900

> David Miller wrote:
> > If you need to provide the source address, you need to pass it in via
> > a new xfrm netlink attribute or use an existing data structure member
> > which records the source address (if any such thing does exist).
> 
> There is no xfrm netlink attribute to carry source address.
> I'll add it like XFRMA_SRCADDR.
> 
> BTW another patch newly defined XFRMA_ADDR to carry care-of address.
> This would be changed e.g. XFRMA_COADDR or something, too.

This sounds fine, thank you.
