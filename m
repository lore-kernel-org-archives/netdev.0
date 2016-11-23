From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Wed, 23 Nov 2016 19:10:16 +0100
Message-ID: <20161123181016.GG8760@lunn.ch>
References: <20161123175546.31416-1-stefan.eichenberger@netmodule.com>
 <20161123175546.31416-2-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
        netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50159 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756801AbcKWSKU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 13:10:20 -0500
Content-Disposition: inline
In-Reply-To: <20161123175546.31416-2-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	[MV88E6097] = {
> +		.prod_num = PORT_SWITCH_ID_PROD_NUM_6097,
> +		.family = MV88E6XXX_FAMILY_6097,
> +		.name = "Marvell 88E6097/88E6097F",
> +		.num_databases = 4096,
> +		.num_ports = 11,
> +		.port_base_addr = 0x10,
> +		.global1_addr = 0x1b,
> +		.age_time_coeff = 15000,
> +		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
> +		.ops = &mv88e6097_ops,

Upps. Sorry, i missed something when you rebased onto net-next. You
are missing .g1_irqs = . It is probably 9. You can check the
datasheet, global 1, register 0. If bit 8 is AVBInt, you need 9. If
bit 8 is reserved, then 8.

    Andrew
