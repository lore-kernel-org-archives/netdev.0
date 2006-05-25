From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [IrDA] *_DONGLE should depend on IRTTY_SIR
Date: Thu, 25 May 2006 16:18:08 -0700 (PDT)
Message-ID: <20060525.161808.102771407.davem@davemloft.net>
References: <20060525061851.GA24611@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15788
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S964808AbWEYXSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 19:18:03 -0400
To: samuel@sortiz.org
In-Reply-To: <20060525061851.GA24611@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Thu, 25 May 2006 06:18:51 +0000

> If a SIR dongle is built in the kernel while IRTTY_SIR is built
> as a module, kernel compilation will fail.
> Thus, the SIR dongle config should depend on the IRTTY_SIR.
> 
> Closes kernel bug# 6512
> (http://bugzilla.kernel.org/show_bug.cgi?id=6512)
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Bug fix, so applied to net-2.6, thanks.
