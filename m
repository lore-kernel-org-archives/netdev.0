From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/23] [PATCH] [XFRM] STATE: Add a hook to find where to
 be inserted header in outbound.
Date: Tue, 01 Aug 2006 21:11:04 -0700 (PDT)
Message-ID: <20060801.211104.34486178.davem@davemloft.net>
References: <11541654231584-git-send-email-nakam@linux-ipv6.org>
	<20060801.170916.21925105.davem@davemloft.net>
	<44D00BEE.8090504@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42137
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751120AbWHBEK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 00:10:57 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44D00BEE.8090504@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Wed, 02 Aug 2006 11:20:30 +0900

> David Miller wrote:
> > I see a dangerous pattern of adding many, many, many methods
> > to the xfrm_type structure which are only used by ipv6.
> > But I cannot suggest another method.
> 
> Sometimes this is a difficult point for me to design.

Do not worry so much about it right now, it is not a barrier
for code integration.  We can try to refine this later on.
