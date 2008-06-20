From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] net: Disable LRO on devices that are forwarding
Date: Fri, 20 Jun 2008 16:21:40 +0200
Message-ID: <87prqc9ogb.fsf@basil.nowhere.org>
References: <cover.1213898165.git.bhutchings@solarflare.com>
	<20080619180735.GT5350@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:10598 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbYFTOWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 10:22:10 -0400
In-Reply-To: <20080619180735.GT5350@solarflare.com> (Ben Hutchings's message of "Thu, 19 Jun 2008 19:07:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> Large Receive Offload (LRO) is only appropriate for packets that are
> destined for the host, and should be disabled if received packets may be
> forwarded.  It can also confuse the GSO on output.
>
> Add dev_disable_lro() function which uses the appropriate ethtool ops to
> disable LRO if enabled.
>
> Add calls to dev_disable_lro() in br_add_if() and functions that enable
> IPv4 and IPv6 forwarding.

It might be a good idea to add a printk so that the user knows why
the device suddenly goes slower.

-Andi
