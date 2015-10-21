From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bcm63xx_enet: check 1000BASE-T advertisement
 configuration
Date: Wed, 21 Oct 2015 06:37:10 -0700 (PDT)
Message-ID: <20151021.063710.39524773982732550.davem@davemloft.net>
References: <562005D6.30204@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037AbbJUNUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 09:20:45 -0400
In-Reply-To: <562005D6.30204@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Arlott <simon@fire.lp0.eu>
Date: Thu, 15 Oct 2015 21:00:22 +0100

> If a gigabit ethernet PHY is connected to a fast ethernet MAC,
> then it can detect 1000 support from the partner but not use it.
> 
> This results in a forced speed of 1000 and RX/TX failure.
> 
> Check for 1000BASE-T support and then check the advertisement
> configuration before setting the MAC speed to 1000mbit.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Applied, thanks.
