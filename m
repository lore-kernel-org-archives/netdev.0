From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 01/24] phy: Consistently use addr for address
 on an MII bus
Date: Mon, 04 Jan 2016 12:01:51 -0800
Message-ID: <568ACFAF.2060804@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35055 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbcADUCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:02:22 -0500
Received: by mail-pf0-f193.google.com with SMTP id e65so19610634pfe.2
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:02:22 -0800 (PST)
In-Reply-To: <1451929022-5580-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Within phy.h, an address on an MII bus has been called both addr and
> phy_id. phy_id is particularly confusion, since it also means the ID
> found in register 3, if the device on the bus is a phy. Consistently
> use addr.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
