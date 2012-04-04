From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 1/2] net/bonding: emit address change event also
 in bond_release
Date: Wed, 04 Apr 2012 18:12:06 -0400 (EDT)
Message-ID: <20120404.181206.1165718268926797089.davem@davemloft.net>
References: <1333529780-28421-1-git-send-email-ogerlitz@mellanox.com>
	<1333529780-28421-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, fubar@us.ibm.com,
	shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756985Ab2DDWMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:12:18 -0400
In-Reply-To: <1333529780-28421-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  4 Apr 2012 11:56:19 +0300

> From: Shlomo Pongratz <shlomop@mellanox.com>
> 
> commit 7d26bb103c4 "bonding: emit event when bonding changes MAC" didn't
> take care to emit the NETDEV_CHANGEADDR event in bond_release, where bonding
> actually changes the mac address (to all zeroes). As a result the neighbours
> aren't deleted by the core networking code (which does so upon getting that
> event).
> 
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>

Applied.
