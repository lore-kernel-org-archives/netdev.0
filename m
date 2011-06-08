From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Tue, 07 Jun 2011 17:27:27 -0700 (PDT)
Message-ID: <20110607.172727.634954568306893152.davem@davemloft.net>
References: <1307389540.2642.3.camel@edumazet-laptop>
	<20110606.130309.847468074358617705.davem@davemloft.net>
	<20110607165134.3e20bb9b@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212Ab1FHA1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 20:27:33 -0400
In-Reply-To: <20110607165134.3e20bb9b@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 7 Jun 2011 16:51:34 -0700

> The problem is that most of the other ioctl's won't work because of use of
> SIOCDEVPRIVATE.

As we discussed we can pass SIOCDEVPRIVATE requests down to the driver
just like we do for all kinds of other compat ioctls.
