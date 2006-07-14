From: David Miller <davem@davemloft.net>
Subject: Re: [SLHC 1/4] Cleanup SLHC configuration
Date: Thu, 13 Jul 2006 22:07:18 -0700 (PDT)
Message-ID: <20060713.220718.10298012.davem@davemloft.net>
References: <20060713110615.GA19816@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27618
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964793AbWGNFHP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 01:07:15 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060713110615.GA19816@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 13 Jul 2006 12:06:15 +0100

> Convert selection of serial line header compression to use CONFIG_SLHC
> rather than makefile ifeq uglyness.  This makes it easier to select
> the SLHC module from other code.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Something is missing here?

I don't see where in the makefiles that you've added
the seemingly necessary:

obj-${CONFIG_SLHC} += slhc.o

line?  How does it get linked in now?

Thanks.
