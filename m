From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Fri, 07 Jul 2006 14:59:32 -0700 (PDT)
Message-ID: <20060707.145932.66155147.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC041BD9C@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@neterion.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8888
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932338AbWGGV7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 17:59:04 -0400
To: mchan@broadcom.com
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BD9C@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 7 Jul 2006 13:57:11 -0700

> RFC3540 is still experimental I believe and it is not implemented
> in the Linux stack.  Even if it is implemented and the NS bit is set,
> I think the TSO logic can simply replicate the NS bit as each TSO
> divided segment contains the same acknowledgement information from
> the original super segment.
> 
> We should hear Herbert, David, or others' opinions on this.

I'm studying the RFC right now just to make sure your assesment is
accurate.  It probably is :)

