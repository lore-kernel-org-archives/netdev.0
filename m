From: David Miller <davem@davemloft.net>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 05:51:15 -0800 (PST)
Message-ID: <20071124.055115.193713164.davem@davemloft.net>
References: <1195893216.4149.186.camel@johannes.berg>
	<20071124133200.GA27531@gondor.apana.org.au>
	<1195912176.4149.194.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, dsd@gentoo.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751938AbXKXNvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2007 08:51:15 -0500
In-Reply-To: <1195912176.4149.194.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 24 Nov 2007 14:49:36 +0100

> 
> On Sat, 2007-11-24 at 21:32 +0800, Herbert Xu wrote:
> > On Sat, Nov 24, 2007 at 09:33:36AM +0100, Johannes Berg wrote:
> > >
> > > We still require four-byte alignment, no?
> > 
> > Not at all.  If NET_IP_ALIGN is zero then it won't be four-byte
> > aligned (since the Ethernet header is 14 bytes long).
> 
> Right. I just didn't think that would be a valid value for an
> architecture to set.

It is, and explicitly used by powerpc to get more of the
DMA transfers 64-byte aligned which is critical for
performance on some powerpc boxes.
