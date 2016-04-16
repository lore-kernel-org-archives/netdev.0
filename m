From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: allow bypassing cross-intf routing limits
Date: Sat, 16 Apr 2016 18:49:36 -0400 (EDT)
Message-ID: <20160416.184936.1899675200733835878.davem@davemloft.net>
References: <1459757755-25424-1-git-send-email-michal.kazior@tieto.com>
	<1460637988-31606-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michal.kazior@tieto.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbcDPWti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 18:49:38 -0400
In-Reply-To: <1460637988-31606-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kazior <michal.kazior@tieto.com>
Date: Thu, 14 Apr 2016 14:46:28 +0200

> There are some use-cases to allow link-local
> routing for bridging purposes.
> 
> One of these is allowing transparent 802.11
> bridging. Due to 802.11 framing limitations many
> Access Points make it impossible to create bridges
> on Client endpoints because they can't maintain
> Destination/Source/Transmitter/Receiver address
> distinction with only 3 addresses in frame header.
> 
> The default behavior, i.e. link-local traffic
> being non-routable, remains. The user has to
> explicitly enable the bypass when defining a given
> route.
> 
> Signed-off-by: Michal Kazior <michal.kazior@tieto.com>

Sorry, whilst I realize your problem, I'm not going to add what is
explicitly a violation of the way link-local addresses are meant to
work and the very much intentional restrictions the RFCs place upon
them (they MUST not be routed).

I also didn't see any real discussions in response to your original
proposals, not from even one person I know is knowledgable about ipv6
and the implications your change would have, and that is extremely
troubling.

I tried to let your patches sit for several days in order to let that
kind of discussion happen, but it didn't.

So, you'll need to find another way to achieve your goals.
