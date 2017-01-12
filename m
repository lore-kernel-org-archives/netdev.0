From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] ARM: dts: am57xx-beagle-x15: implement errata "Ethernet
 RGMII2 Limited to 10/100 Mbps"
Date: Thu, 12 Jan 2017 14:53:32 -0800
Message-ID: <20170112225332.GR2630@atomide.com>
References: <20170112171429.8106-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, linux-omap@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:56998 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750772AbdALWxg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 17:53:36 -0500
Content-Disposition: inline
In-Reply-To: <20170112171429.8106-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Grygorii Strashko <grygorii.strashko@ti.com> [170112 09:15]:
> According to errata i880 description the speed of Ethernet port 1 on AM572x
> SoCs rev 1.1 shuld be limited to 10/100Mbps, because RGMII2 Switching
> Characteristics are not compatible with 1000 Mbps operation [1].
> The issue is fixed with Rev 2.0 silicon.
> 
> Hence, rework Beagle-X15 and Begale-X15-revb1 to use phy-handle instead of
> phy_id and apply corresponding limitation to the Ethernet Phy 1.
> 
> [1] http://www.ti.com/lit/er/sprz429j/sprz429j.pdf

Applying into omap-for-v4.11/dt thanks.

Tony
