From: David Miller <davem@davemloft.net>
Subject: Re: Repost: Re: [VLAN]: translate IF_OPER_DORMANT to
 netif_dormant_on()
Date: Mon, 24 Jul 2006 13:52:35 -0700 (PDT)
Message-ID: <20060724.135235.64808722.davem@davemloft.net>
References: <44AE2FCC.6020207@trash.net>
	<200607120015.17735.stefan@loplof.de>
	<44BE28BB.8020608@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, greearb@candelatech.com, netdev@vger.kernel.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53924
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932171AbWGXUwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 16:52:25 -0400
To: kaber@trash.net
In-Reply-To: <44BE28BB.8020608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 19 Jul 2006 14:42:35 +0200

> Stefan Rompf wrote:
> > [VLAN]: Fix link state propagation
> > 
> > When the queue of the underlying device is stopped at initialization time
> > or the device is marked "not present", the state will be propagated to the
> > vlan device and never change. Based on an analysis by Patrick McHardy.
> 
> ACKed-by: Patrick McHardy <kaber@trash.net>

Applied, and I will queue this up for -stable.
Thanks everyone.
