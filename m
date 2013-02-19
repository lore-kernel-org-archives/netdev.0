From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] bonding: Fix race condition between
 bond_enslave() and bond_3ad_update_lacp_rate()
Date: Tue, 19 Feb 2013 00:52:29 -0500 (EST)
Message-ID: <20130219.005229.193592350299221718.davem@davemloft.net>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
	<21028.1361221753@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980Ab3BSFwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:52:30 -0500
In-Reply-To: <21028.1361221753@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 18 Feb 2013 13:09:13 -0800

> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>>port->slave can be NULL since it's being initialized in bond_enslave
>>thus dereferencing a NULL pointer in bond_3ad_update_lacp_rate()
>>Also fix a minor bug, which could cause a port not to have
>>AD_STATE_LACP_TIMEOUT since there's no sync between
>>bond_3ad_update_lacp_rate() and bond_3ad_bind_slave(), by changing
>>the read_lock to a write_lock_bh in bond_3ad_update_lacp_rate().
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 
>>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied
