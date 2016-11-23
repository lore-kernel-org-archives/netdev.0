From: Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: add MV88E6097 switch
Date: Wed, 23 Nov 2016 21:41:46 +0100
Message-ID: <20161123204146.GA31777@gruene.netmodule.intranet>
References: <20161123175546.31416-1-stefan.eichenberger@netmodule.com>
 <20161123175546.31416-2-stefan.eichenberger@netmodule.com>
 <20161123181016.GG8760@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stefan Eichenberger <eichest@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.netmodule.com ([194.29.26.242]:61739 "EHLO
        webmail.netmodule.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934507AbcKWUlx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 15:41:53 -0500
Content-Disposition: inline
In-Reply-To: <20161123181016.GG8760@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 07:10:16PM +0100, Andrew Lunn wrote:
> > +	[MV88E6097] = {
> > +		.prod_num = PORT_SWITCH_ID_PROD_NUM_6097,
> > +		.family = MV88E6XXX_FAMILY_6097,
> > +		.name = "Marvell 88E6097/88E6097F",
> > +		.num_databases = 4096,
> > +		.num_ports = 11,
> > +		.port_base_addr = 0x10,
> > +		.global1_addr = 0x1b,
> > +		.age_time_coeff = 15000,
> > +		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
> > +		.ops = &mv88e6097_ops,
> 
> Upps. Sorry, i missed something when you rebased onto net-next. You
> are missing .g1_irqs = . It is probably 9. You can check the
> datasheet, global 1, register 0. If bit 8 is AVBInt, you need 9. If
> bit 8 is reserved, then 8.

No problem, bit 8-10 are reserved. So I put 8 in then.

Regards,
Stefan
