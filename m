From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into
 probe/remove
Date: Thu, 19 Apr 2012 18:17:18 +0200
Message-ID: <1334852238.5185.40.camel@sakura.staff.proxad.net>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
	 <1334753296.5185.3.camel@sakura.staff.proxad.net>
	 <CAOiHx=khEqKaAsD++=0BXEzutaWCgi-30B=6hYyLChfkAaHXXA@mail.gmail.com>
	 <1334842380.5185.29.camel@sakura.staff.proxad.net>
	 <CAOiHx==f0czkaEVTe=+wabQMmifdaN00PMQwaR8f-602Dq56pA@mail.gmail.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jonas Gorski <jonas.gorski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:38265 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753860Ab2DSQRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 12:17:17 -0400
In-Reply-To: <CAOiHx==f0czkaEVTe=+wabQMmifdaN00PMQwaR8f-602Dq56pA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2012-04-19 at 16:52 +0200, Jonas Gorski wrote:

> Yes, but none of the ethtool functions cause register writes in the
> priv->has_phy = true case when in PHY_READY or PHY_HALTED state. All
> they do is modify the phy_device's settings.

unless I'm mistaken:

phy_ethtool_sset() => phy_start_aneg()

will kick the state machine even when state is PHY_READY

-- 
Maxime
