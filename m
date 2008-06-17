From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/15]bnx2x: Add TPA, Broadcoms HW LRO
Date: Tue, 17 Jun 2008 16:16:40 -0700 (PDT)
Message-ID: <20080617.161640.256235010.davem@davemloft.net>
References: <1213714166.5817.181.camel@lb-tlvb-eliezer>
	<20080617150539.GJ5350@solarflare.com>
	<20080617151704.GK5350@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com,
	vladz@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38447
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760665AbYFQXQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:16:40 -0400
In-Reply-To: <20080617151704.GK5350@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 Jun 2008 16:17:06 +0100

> Ben Hutchings wrote:
> > Eilon Greenstein wrote:
> > > The TPA stands for Transparent Packet Aggregation. When enabled, the FW
> > > aggregate in-order TCP packets according to the 4-tuple match and sends
> > > 1 big packet to the driver. This packet is stored on an SGL in which
> > > each SGE is 1 page. The FW also implements a timeout algorithm and it
> > > honors all TCP flag, including the push flag as a trigger to halt
> > > aggregation.
> > [...]
> > 
> > LRO is not compatible with forwarding and will currently trigger a BUG() or
> > WARN() if used on packets that are then forwarded.
> 
> Actually, since this implementation doesn't set gso_size in LRO'd skbs, it
> will confuse TCP in interesting ways instead.  You need to set gso_size to
> the largest segment size seen in the packets that were aggregated.

Eilon, please sort this out, thanks.
