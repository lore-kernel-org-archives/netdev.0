From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] bonding: handle slave's name change with
 primary_slave logic
Date: Thu, 16 Jan 2014 17:27:50 -0800 (PST)
Message-ID: <20140116.172750.117356776052290343.davem@davemloft.net>
References: <1389834269-4740-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com, fubar@us.ibm.com,
	andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaAQB1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 20:27:51 -0500
In-Reply-To: <1389834269-4740-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 16 Jan 2014 02:04:29 +0100

> Currently, if a slave's name change, we just pass it by. However, if the
> slave is a current primary_slave, then we end up with using a slave, whose
> name != params.primary, for primary_slave. And vice-versa, if we don't have
> a primary_slave but have params.primary set - we will not detected a new
> primary_slave.
> 
> Fix this by catching the NETDEV_CHANGENAME event and setting primary_slave
> accordingly. Also, if the primary_slave was changed, issue a reselection of
> the active slave, cause the priorities have changed.
> 
> Reported-by: Ding Tianhong <dingtianhong@huawei.com>
> CC: Ding Tianhong <dingtianhong@huawei.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
