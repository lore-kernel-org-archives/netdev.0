From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
Date: Thu, 29 Jun 2006 15:30:37 -0700 (PDT)
Message-ID: <20060629.153037.74747319.davem@davemloft.net>
References: <Pine.GSO.4.10.10606291810490.12773-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, shemminger@osdl.org,
	Leonid.Grossman@neterion.com, Ravinandan.Arakali@neterion.com,
	sivakumar.subramani@neterion.com, Sriram.Rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46487
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933061AbWF2WdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 18:33:13 -0400
To: Ananda.Raju@neterion.com
In-Reply-To: <Pine.GSO.4.10.10606291810490.12773-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ananda Raju <Ananda.Raju@neterion.com>
Date: Thu, 29 Jun 2006 18:18:10 -0400 (EDT)

> 	This patch enables TSO over IPv6. Currently Linux network stacks
> 	restricts TSO over IPv6 by clearing of the NETIF_F_TSO bit from
> 	"dev->features". This patch will remove this restriction.

Generally this looks very good.

Since Herbert Xu has been playing a bit in this area, I'd like
to hear some feedback from him before I apply this.
