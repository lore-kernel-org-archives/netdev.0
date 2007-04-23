From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.22 UDP stalls/hangs
Date: Mon, 23 Apr 2007 13:27:19 -0700
Message-ID: <20070423132719.b7cf1c9e.akpm@linux-foundation.org>
References: <20070423130734.d3d90b20.akpm@linux-foundation.org>
	<20070423.131810.78710074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59813 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752897AbXDWU1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 16:27:23 -0400
In-Reply-To: <20070423.131810.78710074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Apr 2007 13:18:10 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 23 Apr 2007 13:07:34 -0700
> 
> > The interesting bit is:
>  ...
> > I think I saw the same problem maybe 1.5 weeks ago on this machine, but I
> > didn't have time to investigate further.  So it's not some recent thing.
> 
> My initial reaction is that DNS responses are being lost or dropped
> for some reason.

Plausible.   I'll try booting it with the ethernet unplugged.

> Please run tcpdump on the network while this machine comes up and
> see if DNS requests and replies are going back and forth
> correctly.

hm.  That would require a hub and rather a lot of head-scratching.

> Also, please indicate what kind of network card is in this computer.

e1000:

05:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit Ethernet Controller (Copper) (rev 01)

