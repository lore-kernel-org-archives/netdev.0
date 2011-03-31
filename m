From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: Use pr_fmt, netdev_<level>, and netif_<level>
Date: Wed, 30 Mar 2011 21:43:07 -0700 (PDT)
Message-ID: <20110330.214307.63030538.davem@davemloft.net>
References: <1301098883.4132.23.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, jtp.park@samsung.com,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34183
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753869Ab1CaEnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 00:43:45 -0400
In-Reply-To: <1301098883.4132.23.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 25 Mar 2011 17:21:22 -0700

> Use the more common/verbose logging styles.
> 
> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Remove smsc911x prefixes from format strings.
> Rename SMSC_WARNING to SMSC_WARN.
> Remove DPRINTK macro.
> Use netif_<level> in SMSC_<level> macros.
> Convert NETIF_MSG_<foo> uses to lower case.
> Add no_printk verification in non-debug uses.
> Add pdata to SMSC_<level> uses to avoid hidden variable uses.
> Convert printks to netdev_<level> as appropriate.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
