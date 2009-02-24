From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: handle pci bar 0 mapping failure
Date: Tue, 24 Feb 2009 03:44:35 -0800 (PST)
Message-ID: <20090224.034435.130666026.davem@davemloft.net>
References: <1235463419-25146-1-git-send-email-dhananjay@netxen.com>
	<1235463419-25146-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753571AbZBXLoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 06:44:55 -0500
In-Reply-To: <1235463419-25146-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue, 24 Feb 2009 00:16:59 -0800

> PCI bar 0 is used for memory mapped register access.
> If ioremap fails (returns NULL), register access results
> in crash.
> 
> Use pci_ioremap_bar() instead of ioremap(), the latter
> fails on on 32 bit powerpc where pci resource address is
> > 32 bits.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
