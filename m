From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tulip: Fix compiler warning when
 CONFIG_DEBUG_SECTION_MISMATCH=y
Date: Thu, 6 Dec 2012 14:20:12 +0000
Message-ID: <1354803612.20838.22.camel@deadeye.wl.decadent.org.uk>
References: <1354799067-25680-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52412 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932710Ab2LFOUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 09:20:19 -0500
In-Reply-To: <1354799067-25680-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 14:04 +0100, Christoph Paasch wrote:
> WARNING: drivers/net/ethernet/dec/tulip/tulip.o(.text+0x4057): Section
> mismatch in reference from the function tulip_init_one() to the variable
> .devinit.rodata:early_486_chipsets
> The function tulip_init_one() references
> the variable __devinitconst early_486_chipsets.
> This is often because tulip_init_one lacks a __devinitconst
> annotation or the annotation of early_486_chipsets is wrong.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
[...]

The section mismatch will be resolved shortly as hotplug is being made
non-optional and all the __devinit and similar section qualifiers will
go away.  There's no need to make local fixes like this now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
