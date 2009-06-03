From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] forcedeth: Addition of new device id
Date: Wed, 03 Jun 2009 14:57:21 -0700 (PDT)
Message-ID: <20090603.145721.65051603.davem@davemloft.net>
References: <20090603132509.d3121eff.akpm@linux-foundation.org>
	<20090603.142647.149845259.davem@davemloft.net>
	<20090603145238.fd4ece19.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbZFCV5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:57:20 -0400
In-Reply-To: <20090603145238.fd4ece19.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 3 Jun 2009 14:52:38 -0700

> On Wed, 03 Jun 2009 14:26:47 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> Andrew, we do not add new entries to pci_ids.h any more.
> 
> Lots of people are still changing it.

Not enough policing, that's all.  Even I let one slip in recently, but
that was an oversight rather than something I did on purpose. :-)

> I believe that the approach we've been taking is: if the driver
> presently uses pci_ids.h and you're adding a new ID then go for it.
> But new drivers should use a private site for the IDs.  And patches
> which switch old drivers from pci_ids over to a private site are
> approved of.

I think it's silly to let use continue even in those situations.  If
it's in a header file, it's so that it can (at least potentially) be
used in multiple places.  That is not the situation we are handling
here, such defines are always used in exactly one place, the driver ID
table.
