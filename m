From: David Miller <davem@davemloft.net>
Subject: Re: [ROSE] Fix dereference of skb pointer after free.
Date: Mon, 03 Jul 2006 19:29:32 -0700 (PDT)
Message-ID: <20060703.192932.85414750.davem@davemloft.net>
References: <20060630133614.GA11735@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55470
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751370AbWGDC3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:29:16 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060630133614.GA11735@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 30 Jun 2006 14:36:14 +0100

> If rose_route_frame return success we'll dereference a stale pointer.
> Likely this is only going to result in bad statistics for the ROSE
> interface.
> 
> This fixes coverity 946.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
