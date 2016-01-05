From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 20/24] mdio_bus: Add comment to mdiobus_scan()
 and __mdiobus_register()
Date: Mon, 04 Jan 2016 18:02:33 -0800
Message-ID: <568B2439.9040209@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-21-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35979 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAECDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:03:05 -0500
Received: by mail-pa0-f45.google.com with SMTP id yy13so113810452pab.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:03:05 -0800 (PST)
In-Reply-To: <1451929022-5580-21-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Make it clear that mdiobus_scan () will only find devices which have a
> vendor/product ID in registers 2 and 3. These are typically PHY
> devices. Other sort of MDIO devices, such as switches, are not
> expected to be found during the scan.
> 
> Similarly, __mdiobus_register(), which calls mdiobus_scan() will only
> find PHY devices, and other sorts of MDIO devices are expected to be
> instantiated from device tree.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
