From: Alex <alex.g@adaptrum.com>
Subject: Re: net: ti: cpsw-phy-sel: RGMII is not working on AM335x
Date: Wed, 11 Jan 2017 12:18:54 -0800
Message-ID: <fd690450-e2a2-9bc6-1dd5-59cfce4e9caf@adaptrum.com>
References: <1484122463.3777.1.camel@phytec.de>
 <20170111151407.GW22820@lunn.ch> <1484150255.3777.13.camel@phytec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Teresa Remmet <t.remmet@phytec.de>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0072.outbound.protection.outlook.com ([104.47.33.72]:21281
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753335AbdAKUTD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 15:19:03 -0500
In-Reply-To: <1484150255.3777.13.camel@phytec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Teresa

On 01/11/2017 07:57 AM, Teresa Remmet wrote:
> The phy we use is a KSZ9021. And yes we add delays to the
> phy, as you can see. When looking to the dts documentation I probably
> need to set the phy-mode to "rgmii-id" instead, as the phy is providing
> the delays.

Before the change I submitted, every "rgmii*" link was being set up as 
"rgmii-id", regardless of phy-mode. I suspected there might have been 
the odd board here or there that used "rgmii" when the actual mode is 
"rgmii-id".

What confused me the first time around was that I didn't realize the 
delay applies to the phy, not the mac. So "-id" means "the PHY provides 
the delays, so don't add delays on the MAC", just like you realized.

> I make a quick test with that change and it is working. So this seems
> to solve my problem. Thank you for the hint.

I'm glad it was an easy fix. Last time I had issues with RGMII, I had to 
pull out the oscilloscope.

Alex

> Regards,
> Teresa
>
