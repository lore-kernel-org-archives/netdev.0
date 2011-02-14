From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH -next] PCI: fix tlan build when CONFIG_PCI is not enabled
Date: Mon, 14 Feb 2011 23:32:16 +0200
Message-ID: <4D599F60.4010800@iki.fi>
References: <20110214181137.ee8d4c08.sfr@canb.auug.org.au> <20110214122750.e1e03bc8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-pci@vger.kernel.org,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Jesse Barnes <jbarnes@virtuousgeek.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110214122750.e1e03bc8.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
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

Hi Randy,

I think this issue in tlan driver was caused by my recent patch which
added the suspend/resume support to tlan:

<URL:http://marc.info/?l=linux-netdev&m=129564436110754&w=3>

There apparently are tlan cards which are EISA (not PCI) which I forgot
when writing the patch. The suspend/resume has been only tested with PCI
as I have no EISA bus (let alone EISA tlan card!).

I'm going to send a fix to the tlan driver in any case.

Regards,

-- 
Sakari Ailus
sakari.ailus@iki.fi
