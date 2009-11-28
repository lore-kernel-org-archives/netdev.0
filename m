From: David Miller <davem@davemloft.net>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 13:22:54 -0800 (PST)
Message-ID: <20091128.132254.240607445.davem@davemloft.net>
References: <1259337932.3299.3.camel@bigi>
	<20091128151515.GA20476@sch.bme.hu>
	<4B1145F1.3090704@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, hadi@cyberus.ca, hidden@balabit.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46544
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754046AbZK1VWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 16:22:48 -0500
In-Reply-To: <4B1145F1.3090704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 28 Nov 2009 16:46:57 +0100

> Since this patch has already proven to break existing setups, I think
> it should be reverted or the behaviour made optional with a default to
> off.

Absolutely, and fully, agreed.  That is the only criteria for
deciding what to do here, it worked for an enormously long
time and it stopped doing so with the change in question.

"that configuration doesn't make sense" and other such talk
is completely irrelevant.
