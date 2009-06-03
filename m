From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] forcedeth: Addition of new device id
Date: Wed, 3 Jun 2009 14:52:38 -0700
Message-ID: <20090603145238.fd4ece19.akpm@linux-foundation.org>
References: <4A257B1A.8080205@nvidia.com>
	<20090603132509.d3121eff.akpm@linux-foundation.org>
	<20090603.142647.149845259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56315 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753884AbZFCVwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:52:39 -0400
In-Reply-To: <20090603.142647.149845259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 03 Jun 2009 14:26:47 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 3 Jun 2009 13:25:09 -0700
> 
> > On Tue, 02 Jun 2009 15:18:50 -0400
> > Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> > 
> >> This patch adds support for new ethernet device in the MCP89 chipset.
> >> 
> >> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> >> 
> > 
> > It's best to combine these two patches into one, IMO.
> 
> Andrew, we do not add new entries to pci_ids.h any more.

Lots of people are still changing it.  I believe that the approach
we've been taking is: if the driver presently uses pci_ids.h and you're
adding a new ID then go for it.  But new drivers should use a private
site for the IDs.  And patches which switch old drivers from pci_ids
over to a private site are approved of.

> Just use the constant directly when using it in the driver
> ID table.

Well OK, but that means that forcedeth has most of its PCI IDs
enumerated in pci_ids.h, but others hardwired in forcedeth.c.

IOW, Ayaz owes us a "[patch] forcedeth: remove PCI IDs from pci_ids.h" ;)
