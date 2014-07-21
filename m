From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: make it possible to have unlimited
 nested upper vlans
Date: Sun, 20 Jul 2014 20:35:24 -0700 (PDT)
Message-ID: <20140720.203524.1312422901001203305.davem@davemloft.net>
References: <1405609343-3502-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbaGUDf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 23:35:26 -0400
In-Reply-To: <1405609343-3502-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Thu, 17 Jul 2014 17:02:23 +0200

> Currently we're limited by a constant level of vlan nestings, and fail to
> find anything beyound that level (currently 2).
> 
> To fix this - remove the limit of nestings when going through device tree,
> and when the end device is found - allocate the needed amount of vlan tags
> and return them, instead of found/not found.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

Looks good, applied, thanks.
