From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] PCI: fix tlan build when CONFIG_PCI is not
 enabled
Date: Mon, 14 Feb 2011 12:39:32 -0800 (PST)
Message-ID: <20110214.123932.39170183.davem@davemloft.net>
References: <20110214181137.ee8d4c08.sfr@canb.auug.org.au>
	<20110214122750.e1e03bc8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jbarnes@virtuousgeek.org,
	sakari.ailus@iki.fi
To: randy.dunlap@oracle.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20110214122750.e1e03bc8.randy.dunlap@oracle.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 14 Feb 2011 12:27:50 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> When CONFIG_PCI is not enabled, tlan.c has a build error:
> drivers/net/tlan.c:503: error: implicit declaration of function 'pci_wake_from_d3'
> 
> so add an inline function stub for this function to pci.h when
> PCI is not enabled, similar to other stubbed PCI functions.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Sakari Ailus <sakari.ailus@iki.fi>

Acked-by: David S. Miller <davem@davemloft.net>
