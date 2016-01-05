From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 14/24] phy_device: Move phy attributes into
 phy_device
Date: Mon, 04 Jan 2016 17:57:44 -0800
Message-ID: <568B2318.1050103@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-15-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36167 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAEB6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 20:58:16 -0500
Received: by mail-pf0-f174.google.com with SMTP id 65so166272775pff.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 17:58:16 -0800 (PST)
In-Reply-To: <1451929022-5580-15-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> The mdio_bus exports three attributes. However these are all phy
> attributes, not generic mdio attributes. So move the attributes into
> the phy device code.

It could help to mention why just in case you have to respin that patch
series:

- PHY ID is the unique 32-bits identifier for a MDIO device implementing
standard MII registers MII_PHYSID1/2, which is not guaranteed to be the
case for non-standard compliant devices (e.g: Ethernet switches)

- PHY interface describes the data-path of the PHY/MDIO device, which is
not strictly a PHY thing, but is required and needed for PHY devices to
function, a MDIO device could be a control device exclusively

- PHY has fixups describes what the PHY driver may have done, so
completely PHY specific

> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
