From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] skge/sky2 patches for net-next
Date: Wed, 17 Dec 2008 19:33:10 -0800 (PST)
Message-ID: <20081217.193310.216734058.davem@davemloft.net>
References: <20081218000144.964015472@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751994AbYLRDdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 22:33:09 -0500
In-Reply-To: <20081218000144.964015472@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Dec 2008 16:01:44 -0800

> 1-7 have been reviewed several times but not accepted??
> Last one is new.

Stephen, I can't apply the PCI layer changes to the networking tree.

And only the first one even has a review by a PCI hacker.

To top it off, linux-pci and linux-kernel were not even CC'd for a set
of changes that span multiple subsystems.

What do you expect me to do? :-/

I really can't do anything with this patch set as it stands, so they
will all stay not-applied once more.  Please get this work integrated
properly.  First get the PCI changes into the PCI maintainer's tree,
then we can figure out a way to deal with the dependency to get the
sky2 changes into the net-next-2.6 tree.

