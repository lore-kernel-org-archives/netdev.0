From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 5 Oct 2007 14:21:48 -0700
Message-ID: <20071005142148.14c57903@freepuppy.rosehill>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005084036.52dc943c@freepuppy.rosehill>
	<20071005.141217.41646184.davem@davemloft.net>
	<4706A937.3060304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com,
	Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46919 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764116AbXJEVWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:22:31 -0400
In-Reply-To: <4706A937.3060304@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 Oct 2007 17:14:31 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> David Miller wrote:
> > From: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date: Fri, 5 Oct 2007 08:40:36 -0700
> > 
> >> WARNING: braces {} are not necessary for single statement blocks
> >> #691: FILE: drivers/net/niu.c:603:
> >> +	if (lp->loopback_mode == LOOPBACK_PHY) {
> >> +		test_cfg_val |= ((ENET_TEST_MD_PAD_LOOPBACK <<
> >> +				  ENET_SERDES_TEST_MD_0_SHIFT) |
> >> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> >> +				  ENET_SERDES_TEST_MD_1_SHIFT) |
> >> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> >> +				  ENET_SERDES_TEST_MD_2_SHIFT) |
> >> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> >> +				  ENET_SERDES_TEST_MD_3_SHIFT));
> >> +	}
> > 
> > This is why I don't run checkpatch on my work.
> 
> IMO it -is- useful.
> 
> You just have to ignore some of its complaints.  Part of my coding style 
> includes the multiple assignment thing that checkpatch complains about:
> 
> 	status =
> 	msi->status = br32(QDMA_STAT);
> 
> and I am not going to stop doing that just because checkpatch complains :)
> 
> 
> > This statement is a "single statement" but it's broken up
> > into multiple lines for readability, and it make perfect
> > sense to put braces around this basic block so it's easier
> > for humans to see what's going on.
> 
> Strongly agreed.
> 
> 	Jeff

Agreed, don't turn into a bot.
All it's complaints don't have to be fixed, same goes for sparse.
It just helps catch unintentional cruft.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
