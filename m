From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: trap attempts to modify noop qdisc
Date: Wed, 06 Aug 2008 23:11:59 -0700 (PDT)
Message-ID: <20080806.231159.55957179.davem@davemloft.net>
References: <20080806202029.63f25c81@extreme>
	<20080806.202210.92821768.davem@davemloft.net>
	<20080806230850.41435290@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753773AbYHGGL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 02:11:58 -0400
In-Reply-To: <20080806230850.41435290@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Wed, 6 Aug 2008 23:08:50 -0700

> Since noop qdisc is a singleton, it shouldn't end up with any other
> qdisc's on it's list, and it shouldn't be deleted.
> 
> Dave, this should help you find the bug.

Thanks.
