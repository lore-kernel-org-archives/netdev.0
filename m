From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: IXP4xx networking and phylib
Date: Mon, 12 Jan 2009 18:36:44 +0100
Message-ID: <m3wsd0a0k3.fsf@maximus.localdomain>
References: <200901121705.07966.post@hendrik-sattler.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hendrik Sattler <post@hendrik-sattler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:49753 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbZALRgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 12:36:46 -0500
In-Reply-To: <200901121705.07966.post@hendrik-sattler.de> (Hendrik Sattler's message of "Mon\, 12 Jan 2009 17\:05\:07 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Added CC: netdev.

Hendrik Sattler <post@hendrik-sattler.de> writes:

> My IXP465 MII port is connected to a Marvell switch (port 5). This port 
> is "always on" and has no PHY registers. It is configured in hardware. The 
> switch ports 1-4 have phy registers but that's not the matter.
> The problem is that there is no standard way in the platform info to tell the 
> driver (now phylib) that there are _no_ PHY registers.
>
> Is there a standard way to say: enable the ethernet interface and be done with 
> it?
> I currently do this by patching the driver. The PHYLIB patch makes that even 
> easier but it would be better to not need patching at all (at least one 
> driver less to patch).
>
> Maybe something like:
>   if (phyid < 0)
>      /* only enable the interface but there are no PHY registers */
-- 
Krzysztof Halasa
