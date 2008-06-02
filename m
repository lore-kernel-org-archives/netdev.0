From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 2 Jun 2008 18:06:15 -0500
Message-ID: <D5F78DD8-91EC-420F-AF48-DCF4FFF3D386@kernel.crashing.org>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <48442239.7090906@garzik.org> <B2D5CE7E-3635-4C18-BD99-E0B5B0BBC70B@kernel.crashing.org> <48445814.4030004@garzik.org>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60065 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896AbYFBXGb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 19:06:31 -0400
In-Reply-To: <48445814.4030004@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> The whole world isn't embedded ppc, we use this stuff elsewhere too.
>>>
>>> You guys need to figure out something that doesn't require phylib  
>>> be built-in on ALL platforms, but only the platforms that require  
>>> it.
>> I wasn't suggesting we build it always, just not let it be built as  
>> a module.
>
> I was saying, you are requiring everyone to bloat their kernel with  
> phylib, if they enable phylib, because of your particular platform  
> details.
>
> That is not a path we want to follow -- limiting everyone else  
> because of one case is not acceptable.

Are you saying that all the driver subsystems that require being built  
into the kernel should be changed to not require this? (I2C, SPI, DMA  
engine, etc.)

- k
