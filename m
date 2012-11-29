From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: fix race condition in
 bonding_store_slaves_active
Date: Thu, 29 Nov 2012 13:14:10 -0500 (EST)
Message-ID: <20121129.131410.2283343599770817054.davem@davemloft.net>
References: <1353759595-30452-1-git-send-email-nikolay@redhat.com>
	<1354189079-15754-1-git-send-email-nikolay@redhat.com>
	<13839.1354210676@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab2K2SOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:14:11 -0500
In-Reply-To: <13839.1354210676@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 29 Nov 2012 09:37:56 -0800

> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> Race between bonding_store_slaves_active() and slave manipulation 
>> functions. The bond_for_each_slave use in bonding_store_slaves_active()
>> is not protected by any synchronization mechanism.
>> NULL pointer dereference is easy to reach.
>> Fixed by acquiring the bond->lock for the slave walk.
>>
>> v2: Make description text < 75 columns
>>
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
