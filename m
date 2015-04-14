From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 12/12] net/mlx5: Ethernet driver
Date: Tue, 14 Apr 2015 14:51:13 -0400 (EDT)
Message-ID: <20150414.145113.192331451516214119.davem@davemloft.net>
References: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
	<1428999635-15025-13-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com, saeedm@mellanox.com,
	ogerlitz@mellanox.com, achiad@mellanox.com, idos@mellanox.com,
	talal@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbDNSvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 14:51:17 -0400
In-Reply-To: <1428999635-15025-13-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 14 Apr 2015 11:20:35 +0300

> Signed-off-by: Amir Vadai <amirv@mellanox.com>

What does "Ethernet driver" mean?

Are you adding a new ethernet driver?  If so, what is it for and how
does it interact with the existing mlx5 driver?

It looks to me like you are adding a lot of code and objects to the
existing mlx5 module.  An incredible amount, in fact.  This seems very
suboptimal especially for users of the existing mlx5 chips.

You haven't discussed this, what design decisions made you decide
in the end to do it this way, etc.

You absolutely have to say something other than "Ethernet driver"
in this commit message, I expect several paragraphs of details
and the hows and whys of the change as it is a non-trivial amount
of code being added here.

I still consider this patch series not ready yet, and the merge
window is open thus closing the net-next tree.

You will therefore need to wait until the net-next tree opens
again before submitting this series again.

THanks.
