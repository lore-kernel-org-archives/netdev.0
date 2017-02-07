From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next] net: phy: Allow splitting MDIO bus/device support
 from PHYs
Date: Mon, 6 Feb 2017 16:01:27 -0800
Message-ID: <34f35da1-086a-0809-b962-7d0dbcf9df8d@gmail.com>
References: <20170131032931.1494-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        rmk+kernel@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35081 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGAB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 19:01:29 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so10326694pge.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 16:01:29 -0800 (PST)
In-Reply-To: <20170131032931.1494-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2017 07:29 PM, Florian Fainelli wrote:
> Introduce a new configuration symbol: MDIO_DEVICE which allows building
> the MDIO devices and bus code, without pulling in the entire Ethernet
> PHY library and devices code.
> 
> PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
> updated to reflect that.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Andrew, Russell, does that seem sensible to you, shall I re-submit this
as a proper patch?
-- 
Florian
