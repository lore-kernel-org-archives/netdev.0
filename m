From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 02 Jun 2008 18:20:00 -0500
Message-ID: <48448020.5020407@freescale.com>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>	<484419EE.5040503@garzik.org>	<1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>	<48442239.7090906@garzik.org>	<BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org>	<83820D83-487C-4586-9867-F4226A87A276@freescale.com>	<48445851.4090105@garzik.org> <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:63603 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbYFBXUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 19:20:15 -0400
In-Reply-To: <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> On Jun 2, 2008, at 3:30 PM, Jeff Garzik wrote:
> 
>> Andy Fleming wrote:
>>> I'm partial to the select-it-if-you-need-it paradigm.
>>
>>
>> AFAICS this can all be solved by the platform Kconfig ensuring that 
>> phylib=y
> 
> I don't care for this as it means making sure each platform/board port 
> gets it right.

How is this different from any other kconfig dependency?  It's not too 
hard to scan through your platform code and see what you call...

> I think we'd be better off with a small stub that is 
> always built into the kernel for phy_read/phy_write, etc or the function 
> pointer indirection mechanism.

And then instead of build failures, you'd get a silent runtime failure 
to apply the workaround if phylib is built as a module.

-Scott
