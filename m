From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: make unexported functions static
Date: Thu, 09 Jun 2016 08:44:38 -0400
Message-ID: <87fusm8rbd.fsf@ketchup.mtl.sfl>
References: <1465468206-2890-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	Andrew Lunn <andrew@lunn.ch>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33515 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbcFIMom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 08:44:42 -0400
In-Reply-To: <1465468206-2890-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Ben Dooks <ben.dooks@codethink.co.uk> writes:

> The driver has a number of functions that are not exported or
> declared elsewhere, so make them static to avoid the following
> warnings from sparse:
>
> drivers/net/dsa/mv88e6xxx.c:113:5: warning: symbol 'mv88e6xxx_reg_read' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx.c:167:5: warning: symbol 'mv88e6xxx_reg_write' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx.c:231:5: warning: symbol 'mv88e6xxx_set_addr' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx.c:367:6: warning: symbol 'mv88e6xxx_ppu_state_init' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx.c:3157:5: warning: symbol 'mv88e6xxx_phy_page_read' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx.c:3169:5: warning: symbol 'mv88e6xxx_phy_page_write' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx.c:3583:26: warning: symbol 'mv88e6xxx_switch_driver' was not declared. Should it be static?
> drivers/net/dsa/mv88e6xxx.c:3621:5: warning: symbol 'mv88e6xxx_probe' was not declared. Should it be static?
>
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Most of them are fixed or being handled in net-next.

I don't know if net should diverge or if it can live with these
warnings...

Thanks,

        Vivien
