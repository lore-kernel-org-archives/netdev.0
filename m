From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: bcm_sf2: Add support for
 IPv6 CFP rules
Date: Mon, 23 Oct 2017 03:11:51 +0100 (WEST)
Message-ID: <20171023.031151.1099742173523833308.davem@davemloft.net>
References: <20171020213949.16485-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdJWCL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 22:11:57 -0400
In-Reply-To: <20171020213949.16485-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 20 Oct 2017 14:39:42 -0700

> This patch series adds support for matching IPv6 addresses to the existing CFP
> support code. Because IPv6 addresses are four times bigger than IPv4, we can
> fit them anymore in a single slice, so we need to chain two in order to have
> a complete match. This makes us require a second bitmap tracking unique rules
> so we don't over populate the TCAM.
> 
> Finally, because the code had to be re-organized, it became a lot easier to
> support arbitrary prefix/mask lengths, so the last two patches do just that.

Series applied, thanks Florian.
