From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/bonding: bonding: Adjust coding style for bond_3ad
 files.
Date: Wed, 04 May 2011 16:49:53 -0700
Message-ID: <1304552993.1788.135.camel@Joe-Laptop>
References: <20110504221844.GA17955@x61.tchesoft.com>
	 <20110504163803.57cde72e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rafael Azenha Aquini <aquini@linux.com>,
	kernel-janitors.vger.kernel.org@x61.tchesoft.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1262 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755826Ab1EDXty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 19:49:54 -0400
In-Reply-To: <20110504163803.57cde72e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 16:38 -0700, Stephen Hemminger wrote:
> On Wed, 4 May 2011 19:18:47 -0300
> Rafael Azenha Aquini <aquini@linux.com> wrote:
> > -// compare MAC addresses
> >  #define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
> >  static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
> These should be changed to use compare_ether_addr and is_zero_ether_addr
> routines in etherdevice.h

Hey Stephen.

null_mac_addr is used as a struct and should not be changed
to is_zero_ether_addr.
Maybe the uses could be changed to a memset, but I seem to
recall the code gets bigger.

drivers/net/bonding/bond_3ad.c:1637:		aggregator->partner_system = null_mac_addr;
drivers/net/bonding/bond_3ad.c:1660:		aggregator->aggregator_mac_address = null_mac_addr;
drivers/net/bonding/bond_3ad.c:1696:		port->actor_system = null_mac_addr;


