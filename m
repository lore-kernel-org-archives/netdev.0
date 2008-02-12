From: David Miller <davem@davemloft.net>
Subject: Re: [patch 6/7] hci_ldisc: fix null pointer deref
Date: Mon, 11 Feb 2008 21:42:18 -0800 (PST)
Message-ID: <20080211.214218.251819811.davem@davemloft.net>
References: <200802050748.m157m0ne010461@imap1.linux-foundation.org>
	<20080205.031129.40584551.davem@davemloft.net>
	<1202230268.15090.105.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	david@davidnewall.com, alan@lxorguk.ukuu.org.uk,
	arjan@linux.intel.com
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48450
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752535AbYBLFlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 00:41:47 -0500
In-Reply-To: <1202230268.15090.105.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 05 Feb 2008 17:51:07 +0100

> Hi David,
> 
> > > akpm:
> > > 
> > >   No idea.  trollmerge.
> > > 
> > > Cc: Arjan van de Ven <arjan@linux.intel.com>
> > > Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> > > Cc: Marcel Holtmann <marcel@holtmann.org>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > I'll let Marcel and/or Alan take a look at this one.
> 
> we might have to re-work the whole hci_uart driver at some point, but
> for now I think this fix is feasible.

Ok, I've applied this patch.
