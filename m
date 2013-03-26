From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: cleanup unneeded rcu_read_lock()
Date: Tue, 26 Mar 2013 12:50:07 -0400 (EDT)
Message-ID: <20130326.125007.36370421934179455.davem@davemloft.net>
References: <1364307002-11242-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab3CZQuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:50:09 -0400
In-Reply-To: <1364307002-11242-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 26 Mar 2013 15:10:02 +0100

> bond_resend_igmp_join_requests_delayed() calls _resend_igmp_join_requests()
> under rcu_read_lock(), while it gets its own rcu_read_lock() for the whole
> function. Remove the lock from the _delayed function.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied.
