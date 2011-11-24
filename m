From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netxen: write IP address to firmware when
 using bonding
Date: Thu, 24 Nov 2011 00:38:55 -0500 (EST)
Message-ID: <20111124.003855.1498231373002177172.davem@davemloft.net>
References: <1322073791-15223-1-git-send-email-andy@greyhouse.net>
	<20111123.160922.1983654308126240492.davem@davemloft.net>
	<20111124032426.GG25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab1KXFjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 00:39:06 -0500
In-Reply-To: <20111124032426.GG25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 23 Nov 2011 22:24:27 -0500

> Are you talking about adding a macro like this:
> 
> 	for_each_dev_in_bond(bond,slave) {
> 		[...]
> 	}
> 
> to replace the statements I added that were like this:
> 
> 	for_each_netdev_rcu(&init_net, slave) {
> 		if (slave->master == dev) {
> 			[...]
> 		}
> 	}
> 
> If so, that totally seems reasonable.  If were requesting something
> else, please let me know.

Yes, some helper that walks the device list and tries to find
a device whose ->master matches 'dev'.
