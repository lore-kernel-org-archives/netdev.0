From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 03 Jun 2008 12:06:40 -0700 (PDT)
Message-ID: <20080603.120640.151150916.davem@davemloft.net>
References: <20080603104640.21026cdb@extreme>
	<20080603.105308.196677970.davem@davemloft.net>
	<20080603113411.0af753d8@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751244AbYFCVgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:36:51 -0400
In-Reply-To: <20080603113411.0af753d8@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 3 Jun 2008 11:34:11 -0700

> On Tue, 03 Jun 2008 10:53:08 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > If it's a route behavioral attribute, make it as such and add
> > a new rtnetlink route attribute.  If it's not there, existing
> > behavior is maintained.
> 
> How would this work for system generated routes which occur
> when address is added to interface?

Ok, then this takes us back to making userland take care of it.

You say this is difficult, by how different is this from any
other kind of event response and synchronization that these
routing daemons have to do already?
