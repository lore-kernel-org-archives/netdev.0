From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 04 Dec 2015 23:50:36 -0500 (EST)
Message-ID: <20151204.235036.1511254463749836388.davem@davemloft.net>
References: <1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
	<20151204.150633.1744714566987717806.davem@davemloft.net>
	<CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, tom@herbertland.com,
	linville@tuxdriver.com, jesse@kernel.org, anjali.singhai@intel.com,
	netdev@vger.kernel.org, kiran.patil@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbbLEEuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 23:50:40 -0500
In-Reply-To: <CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 4 Dec 2015 14:44:00 -0800

> I actually tried to push the generic checksum idea for fm10k back
> during hardware development but ended up losing that battle.

This chips already have a circuit calculating the 1's complement sum
over the data as is passed through the FIFO in the RTL, it's merely a
matter of putting the result it in the descriptor.

Relatively speaking, the feature would be almost free.
