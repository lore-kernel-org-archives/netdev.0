From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 2 Jun 2008 18:07:52 -0500
Message-ID: <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <48442239.7090906@garzik.org> <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org> <83820D83-487C-4586-9867-F4226A87A276@freescale.com> <48445851.4090105@garzik.org>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36394 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755357AbYFBXIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 19:08:06 -0400
In-Reply-To: <48445851.4090105@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 2, 2008, at 3:30 PM, Jeff Garzik wrote:

> Andy Fleming wrote:
>> I'm partial to the select-it-if-you-need-it paradigm.
>
>
> AFAICS this can all be solved by the platform Kconfig ensuring that  
> phylib=y

I don't care for this as it means making sure each platform/board port  
gets it right.  I think we'd be better off with a small stub that is  
always built into the kernel for phy_read/phy_write, etc or the  
function pointer indirection mechanism.

- k
