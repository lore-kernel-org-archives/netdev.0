From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/5] net: dsa: LAG support
Date: Mon, 2 Oct 2017 14:51:09 +0200
Message-ID: <20171002125109.GA4765@lunn.ch>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:35518 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750957AbdJBMvO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 08:51:14 -0400
Content-Disposition: inline
In-Reply-To: <20171001194639.8647-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> - not sure what to do with a switch fabric, naively, if adding two ports
>   of two distinct switches as a LAG group, we may have to propagate that
>   to "dsa" cross-chip interfaces as well

Hi Florian

Marvell switches do support this. If i remember correctly, it requires
some setup for forwarding over the DSA ports.

But for a first implementation, i would be tempted to disallow such
setups. Force the LAG members to be on the same switch.

	Andrew
