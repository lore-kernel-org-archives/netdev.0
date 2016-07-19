From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 19 Jul 2016 10:49:57 -0700
Message-ID: <1468950597.1900.56.camel@perches.com>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
	 <20160715050005.GD30603@leon.nu> <578E0A65.1020105@annapurnalabs.com>
	 <20160719172644.GK20674@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, benjamin.poirier@gmail.com,
	ben@decadent.org.uk, romieu@fr.zoreil.com, rami.rosen@intel.com,
	antoine.tenart@free-electrons.com
To: Leon Romanovsky <leon@kernel.org>,
	Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719172644.GK20674@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-07-19 at 20:26 +0300, Leon Romanovsky wrote:
> On Tue, Jul 19, 2016 at 02:09:25PM +0300, Netanel Belgazal wrote:
> > This is the debugging message interface.
> > https://www.kernel.org/doc/Documentation/networking/netif-msg.txt
> This document was updated last time in 2006 and I doubt that it is
> relevant in 2016. You have dynamic debug prints infrastructure for it,
> use it.

I think this is uninformed.

netif_<level> works well, is compatible with dynamic debug,
and is commonly used with new networking drivers.
