From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 15:11:35 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021506560.32431@router.home>
References: <1275496439.2725.203.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021140320.30182@router.home>  <20100602.101258.134121018.davem@davemloft.net>  <20100602.103102.121237521.davem@davemloft.net>  <1275500802.2519.7.camel@edumazet-laptop>
 <alpine.DEB.2.00.1006021255001.32431@router.home>  <1275504070.2519.12.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021355040.32431@router.home> <1275506732.2519.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:47164 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865Ab0FBULr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 16:11:47 -0400
In-Reply-To: <1275506732.2519.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jun 2010, Eric Dumazet wrote:

>
> Say we have eth0 on 192.168.0.1/24 and eth1 on 192.168.0.2/24
>
> Then we cannot use rp_filter = 1, even with unicast trafic.
>
> I really dont understand why you would setup rp_filter in such a
> situation. This wont work.

rp_filter was setup in the past and it worked. Stephen fixed it in 2.6.31
for multicast and thus suddenly multicast stopped working on secondary
interfaces when we moved to 2.6.32. rp_filter having to be off is okay but
it does not feel correct.

> Now, I agree we should have a counter somewhere to help admins to
> understand their error ;)

Ah. Good.

> Here is patch I am currently testing.
>
> I finaly created a new counter, because its a linux specific check.

Looks good which does not say too much given my limited networking
knowledge.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
