From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.21-rc5-mm3: fix e1000 compilation
Date: Fri, 30 Mar 2007 14:20:25 -0700 (PDT)
Message-ID: <20070330.142025.02298139.davem@davemloft.net>
References: <20070330100104.9b770cd8.akpm@linux-foundation.org>
	<20070330100709.44127796.randy.dunlap@oracle.com>
	<460D4896.9090302@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, adobriyan@sw.ru,
	randy.dunlap@oracle.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754073AbXC3VvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 17:51:16 -0400
In-Reply-To: <460D4896.9090302@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Fri, 30 Mar 2007 10:27:50 -0700

> turns out that NETIF_F_TSO6 is defined even if CONFIG_IPV6 is turned
> off, which is what broke e1000. That in itself might be a
> problem. Perhaps this should be fixed in netdevice.h (gratuitous bad
> inline patch below) but I'm not sure if people would appreciate
> this, as it's rather ugly, and it gets all horrible when people
> disable TCP protocol support...

No, I don't think we should do this.

We have the vlan acceleration flags available when 802.1Q is
disabled, same situation, and just as valid.
