From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] davinci_emac: fix setting the mac from DT
Date: Thu, 20 Oct 2016 05:41:50 -0700
Message-ID: <20161020124149.v47amnfbisndai4q@atomide.com>
References: <1476904973-13226-1-git-send-email-jhofstee@victronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Anant Gole <anantgole@ti.com>,
        Chaithrika U S <chaithrika@ti.com>,
        linux-omap@vger.kernel.org
To: Jeroen Hofstee <jhofstee@victronenergy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:45462 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755139AbcJTMlx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 08:41:53 -0400
Content-Disposition: inline
In-Reply-To: <1476904973-13226-1-git-send-email-jhofstee@victronenergy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jeroen Hofstee <jhofstee@victronenergy.com> [161019 12:39]:
> commit 9120bd6e9f77 ("net: davinci_emac: Get device dm816x MAC address
> using the cpsw code") sets the mac address to the one stored in the chip
> unconditionally, overwritten the one already set from the device tree.
> This patch makes sure the mac from DT is preserved.
> 
> On a am3517 this address is incorrectly read as all zeros, making it
> impossible to set a valid mac address without this patch.

OK, at least I don't have better ideas for fixing this:

Acked-by: Tony Lindgren <tony@atomide.com>
