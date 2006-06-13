From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 3/6] bnx2: Use CPU native page size
Date: Tue, 13 Jun 2006 15:41:13 -0700 (PDT)
Message-ID: <20060613.154113.133441489.davem@davemloft.net>
References: <1150157833.26173.8.camel@rh4>
	<20060612.222036.15588314.davem@davemloft.net>
	<1150222782.26368.34.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7855
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932318AbWFMWlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 18:41:16 -0400
To: mchan@broadcom.com
In-Reply-To: <1150222782.26368.34.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 13 Jun 2006 11:19:42 -0700

> Use CPU native page size to determine various ring sizes. This allows
> order-0 memory allocations on all systems.
> 
> Added check to limit the page size to 16K since that's the maximum rx
> ring size that will be used. This will prevent using unnecessarily
> large page sizes on some architectures with large page sizes.
> [Suggested by David Miller]
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks great, applied.
