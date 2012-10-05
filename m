From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: EG20T and Micrel KSZ9021 Gigabit Ethernet
Date: Fri, 5 Oct 2012 21:53:43 +0200
Message-ID: <20121005195343.GA7083@electric-eye.fr.zoreil.com>
References: <506F30A2.500@intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Kosin <jkosin@intcomgrp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36554 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567Ab2JEUNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 16:13:25 -0400
Content-Disposition: inline
In-Reply-To: <506F30A2.500@intcomgrp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Kosin <jkosin@intcomgrp.com> :
[...]
> I'm tempted to reconfigure to remove that; but, am afraid that there is
> no other driver for the network.  The only other set of drivers that
> seem to be related are for the intel directory; but, these seem to be
> intel specific.  I don't see support for this combination.
> 
> Anyone have an idea where I need to start?

drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
[...]
        pr_info("EG20T PCH Gigabit Ethernet Driver - version %s\n",DRV_VERSION);

It would seem a sensible candidate driver for your chipset (EG20T) built-in MAC.

Why do you want to use something else ?

-- 
Ueimor
