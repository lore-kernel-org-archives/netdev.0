From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Disallow providing non zero VLAN ID for NIC
 drivers FDB add flow
Date: Tue, 16 Dec 2014 15:41:53 -0500 (EST)
Message-ID: <20141216.154153.2279692705217347585.davem@davemloft.net>
References: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	gospo@cumulusnetworks.com, jhs@mojatatu.com,
	john.r.fastabend@intel.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaLPUl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:41:59 -0500
In-Reply-To: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 14 Dec 2014 18:19:05 +0200

> The current implementations all use dev_uc_add_excl() and such whose API
> doesn't support vlans, so we can't make it with NICs HW for now.
> 
> Fixes: f6f6424ba773 ('net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
