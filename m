From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Fri, 29 Sep 2006 16:29:58 -0700 (PDT)
Message-ID: <20060929.162958.102576741.davem@davemloft.net>
References: <451DA57F.60609@garzik.org>
	<20060929.160807.28788865.davem@davemloft.net>
	<451DA902.7030409@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36544
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932283AbWI2X34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 19:29:56 -0400
To: jeff@garzik.org
In-Reply-To: <451DA902.7030409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 29 Sep 2006 19:15:14 -0400

> It was completely vague as to why this incompatibility was specific to 
> the 5706, when -- as the description noted -- the behavior is legal.
> 
> Re-read the patch.  At no time does it say 5706 was in the wrong.

True, but it does indicate that using a masked 64-bit transaction
for MSI instead of a true 32-bit one is considered to be quite rare.

Do you wish to put a table of all devices that do this, and at PCI
quirk time disable PCI for everyone on the AMD chipset if even one
such device is found in the device?

That doesn't make any sense to me.
