From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 23 Nov 2015 14:54:33 -0500 (EST)
Message-ID: <20151123.145433.1554000376541433305.davem@davemloft.net>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
	<1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
	<CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	kernel-team@fb.com, davewatson@fb.com, alexei.starovoitov@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108AbbKWTyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 14:54:36 -0500
In-Reply-To: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 23 Nov 2015 09:33:44 -0800

> The TCP PSH flag is not defined for message delineation (neither is
> urgent pointer). We can't change that (many people have tried to add
> message semantics to TCP protocol but have always failed miserably).

Agreed.

My only gripe with kcm right now is a lack of a native sendpage.
We should be able to zero copy data through KCM streams without
any problems whatsoever.
