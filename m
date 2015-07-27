From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Move temperature sensor code
 to mv88e6xxx.c
Date: Mon, 27 Jul 2015 01:20:42 -0700 (PDT)
Message-ID: <20150727.012042.363501071834365706.davem@davemloft.net>
References: <1437842548-7233-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
	netdev@vger.kernel.org, andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbbG0IUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:20:44 -0400
In-Reply-To: <1437842548-7233-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Sat, 25 Jul 2015 09:42:28 -0700

> Move the temperature sensing code for mv88e6352 and mv88e6320 families
> into mv88e6xxx.c to simplify adding support for additional chips.
> 
> With this change, mv88e6xxx_6320_family() no longer needs to be
> a global function and is made static.
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
