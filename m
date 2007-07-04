From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] ucc_geth.c, make PHY device optional.
Date: Wed, 4 Jul 2007 15:32:20 +0200
Message-ID: <B27F0350-E5ED-48BF-9605-1E6BE29B9E36@kernel.crashing.org>
References: <989B956029373F45A0B8AF0297081890D839B4@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <joakim.tjernlund@transmode.se>,
	linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
To: Li Yang-r58472 <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40453 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760637AbXGDNcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 09:32:43 -0400
In-Reply-To: <989B956029373F45A0B8AF0297081890D839B4@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> How about separate autoneg to a property "dumb-phy", which  
> indicates the
> PHY/switch doesn't provide MII register interface.

Something like that I suppose.  But don't call it "dumb phy",
nor "fake phy", nor anything similar -- there simply is _no_
phy.  If the Linux code wants to pretend there is one, that's
one thing, but there is no need to do any of this trickery in
the device tree.

> Therefore, it should
> use the fixed speed and duplex from device node rather than registers.

Yes.


Segher

