From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5] mv643xx_eth: allow multiple instances
Date: Tue, 29 Apr 2008 01:51:30 -0400
Message-ID: <4816B762.3070600@garzik.org>
References: <20080423232642.GB17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57858 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355AbYD2Fvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:51:35 -0400
In-Reply-To: <20080423232642.GB17159@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> This (bisectable) patch series (posted previously to netdev@ on Mar
> 17 and on Mar 19) allows instantiating multiple mv643xx_eth instances,
> which is necessary for newer chips that contain multiple mv643xx_eth
> silicon blocks, and adds support for programming mv643xx_eth's mbus
> address window registers.
> 
> These five patches were not merged in the initial batch of
> mv643xx_eth patches that went into 2.6.25-git because they depend
> on a0916bd64a0e6636f0161480e04057c89e90c5da ("[POWERPC] mv643xx_eth:
> Prepare to support multiple silicon blocks") to be merged first,
> which has now been merged (via the powerpc tree.)

looks fine to me.  I'll assume the maintainer will send me a pull 
request or something...


