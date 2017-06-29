From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] net: stmmac: support future possible different
 internal phy mode
Date: Thu, 29 Jun 2017 12:23:49 -0400 (EDT)
Message-ID: <20170629.122349.2265868886957558079.davem@davemloft.net>
References: <20170627092806.28181-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
        maxime.ripard@free-electrons.com, wens@csie.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        andre.przywara@arm.com, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-sunxi@googlegroups.com
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42268 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbdF2QXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:23:52 -0400
In-Reply-To: <20170627092806.28181-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Tue, 27 Jun 2017 11:28:01 +0200

> The current way to find if the phy is internal is to compare DT phy-mode
> and emac_variant/internal_phy.
> But it will negate a possible future SoC where an external PHY use the
> same phy mode than the internal one.
> 
> By using phy-mode = "internal" we permit to have an external PHY with
> the same mode than the internal one.
> 
> Reported-by: André Przywara <andre.przywara@arm.com>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Series applied.

Please provide a proper "[PATCH 0/n] " header posting next time.
