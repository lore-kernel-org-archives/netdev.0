From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] dsa: mv88e6xxx: hide unused functions
Date: Thu, 23 Jun 2016 11:21:27 -0400
Message-ID: <87fus4x760.fsf@ketchup.mtl.sfl>
References: <20160623141409.356324-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48267 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbcFWPVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 11:21:32 -0400
In-Reply-To: <20160623141409.356324-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Arnd Bergmann <arnd@arndb.de> writes:

> When CONFIG_NET_DSA_HWMON is disabled, we get warnings about two unused
> functions whose only callers are all inside of an #ifdef:
>
> drivers/net/dsa/mv88e6xxx.c:3257:12: 'mv88e6xxx_mdio_page_write' defined but not used [-Werror=unused-function]
> drivers/net/dsa/mv88e6xxx.c:3244:12: 'mv88e6xxx_mdio_page_read' defined but not used [-Werror=unused-function]
>
> This adds another ifdef around the function definitions. The warnings
> appeared after the functions were marked 'static', but the problem
> was already there before that.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 57d3231057e9 ("net: dsa: mv88e6xxx: fix style issues")

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

David, this patch is meant for net-next. It applies cleanly *before* my
last two submissions:

    1/2 http://patchwork.ozlabs.org/patch/638773/
    2/2 http://patchwork.ozlabs.org/patch/638772/

Thanks,

        Vivien
