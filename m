From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bonding: fix enslaving a dev without mtu
 setting support
Date: Thu, 22 May 2014 15:47:06 -0400 (EDT)
Message-ID: <20140522.154706.1268896686458226593.davem@davemloft.net>
References: <1400686921-5698-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaEVTrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:47:09 -0400
In-Reply-To: <1400686921-5698-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Wed, 21 May 2014 17:41:59 +0200

> With the introduction of bond_free_slave() we need to have slave->bond
> populated before calling it, however if the dev_mtu_set(slave, mtu) fails,
> we call bond_free_slave() before actually setting slave->bond, and thus
> we'll panic.
> 
> Fix this by populating slave->bond (and ->dev, it seems appropriate) as
> early as possible.
> 
> Also, remove a harmful check for NULL in bond_get_bond_by_slave(), as it's
> only hiding the real problem and making it harder to debug.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: netdev@vger.kernel.org
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

Series applied to net-next, thanks.
