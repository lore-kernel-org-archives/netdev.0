From: David Miller <davem@davemloft.net>
Subject: Re: doubt about qla3xxx checksum "fix"
Date: Sun, 03 Jun 2007 19:03:25 -0700 (PDT)
Message-ID: <20070603.190325.112029409.davem@davemloft.net>
References: <20070603.180051.89019554.davem@davemloft.net>
	<20070603185059.7f1e76cd@freepuppy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbXFDCDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 22:03:11 -0400
In-Reply-To: <20070603185059.7f1e76cd@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sun, 3 Jun 2007 18:50:59 -0700

> On Sun, 03 Jun 2007 18:00:51 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > 
> > I don't think it's %100 right, I'm referring specifically to
> > 
> > e68a8c10c4c5daf363e946d10c1a5cba77d7f92c
> > 
> > Sure, qla3xxx is only handling ipv4 in that ql_hw_csum_setup()
> > function, but if you check the call site it really wants
> > CHECKSUM_PARTIAL skb's to work on.  And CHECKSUM_PARTIAL skbs are only
> > setup for paths that advertise the NETIF_F_HW_CSUM capability.
> 
> CHECKSUM_PARTIAL is used on xmit for both NETIF_F_HWCSUM and NETIF_F_IPCSUM 
> See acenic, 3c59x, ...

I missed that, thanks a lot Stephen.
