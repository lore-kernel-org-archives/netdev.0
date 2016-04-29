From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/11] Mellanox 100G extending mlx5 ethtool
 support
Date: Fri, 29 Apr 2016 16:34:46 -0400 (EDT)
Message-ID: <20160429.163446.928550855039136205.davem@davemloft.net>
References: <CALzJLG-BJvB7h2wAOqy8ibDdkw7Croaiy7+QU9izrcivuS1yOg@mail.gmail.com>
	<20160426.174150.2239494413467110.davem@davemloft.net>
	<CALzJLG_a4s54MwCzOHMeCp0i5F5pyb-PHY_AFA-ok2JT5S62wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	talal@mellanox.com, eranbe@mellanox.com
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbcD2Ues (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:34:48 -0400
In-Reply-To: <CALzJLG_a4s54MwCzOHMeCp0i5F5pyb-PHY_AFA-ok2JT5S62wQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Fri, 29 Apr 2016 23:27:06 +0300

> but my concerns is when features A and B requires firmware commands A then B
> and firmware command B fails, there is no gurantee that roll back for
> firmware command A will work.
> 
> this is why in case of B fails we keep the state (new A and prev B)
> rather than try to go back to (prev A and prev B).

That's a limitation of your firmware I would say.

Users do not expect the semantics you will be providing, if "change A and B"
fails both states must not be changed.

This is an unwavering requirement, you must do everything you can to
meet that expection.

You cannot say "our firmware does this so, you might get partial
updates."  That simply is not acceptable.
