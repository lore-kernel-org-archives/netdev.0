From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 3/4] net: mvmdio: slight optimisation of
 orion_mdio_write
Date: Sat, 26 Oct 2013 01:45:45 -0400 (EDT)
Message-ID: <20131026.014545.318441640809669571.davem@davemloft.net>
References: <cover.1382199042.git.leigh@solinno.co.uk>
	<cover.1382637156.git.leigh@solinno.co.uk>
	<6d044f3760cd506a325d5aab1199131ade96d632.1382637156.git.leigh@solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	sebastian.hesselbarth@gmail.com
To: leigh@solinno.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3JZFpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 01:45:47 -0400
In-Reply-To: <6d044f3760cd506a325d5aab1199131ade96d632.1382637156.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leigh Brown <leigh@solinno.co.uk>
Date: Thu, 24 Oct 2013 19:09:33 +0100

> Make only a single call to mutex_unlock in orion_mdio_write.
> 
> Signed-off-by: Leigh Brown <leigh@solinno.co.uk>

You patch does more than what you're talking about here in your
commit message.  In particular you're also changing the interpretation
of the orion_mdio_wait_ready() return value by changing the test
from < 0 to != 0.

Even if that is a legitimate change:

1) You're not describing it in the commit message at all.

2) It's a logically separate change, so should go into a completely
   separate patch.
