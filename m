From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 11/24] phy: Add an mdio_device structure
Date: Mon, 04 Jan 2016 17:53:12 -0800
Message-ID: <568B2208.3060502@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-12-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33192 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbcAEBxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 20:53:45 -0500
Received: by mail-pa0-f44.google.com with SMTP id cy9so206189507pac.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 17:53:44 -0800 (PST)
In-Reply-To: <1451929022-5580-12-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Not all devices attached to an MDIO bus are phys. So add an
> mdio_device structure to represent the generic parts of an mdio
> device, and place this structure into the phy_device.

This looks good to me, I am just wondering if it would make sense to
introduce another patch, prior to this one which does something like:

- expose phydev_addr(phydev) to encapsulate the phy device's addr member
and convert all drivers listed here to that helper, do the same thing
with phydev_bus(phydev) to get the mii_bus of a given PHY device

- have a subsequent patch which relocates phydev->{addr,bus} to the
common MDIO device structure?

Other than that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
