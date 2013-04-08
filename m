From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bonding: fix bonding_masters race condition in
 bond unloading
Date: Mon, 08 Apr 2013 16:45:26 -0400 (EDT)
Message-ID: <20130408.164526.147100963232725098.davem@davemloft.net>
References: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
	<1365245678-4455-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762581Ab3DHUp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:45:28 -0400
In-Reply-To: <1365245678-4455-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat,  6 Apr 2013 12:54:38 +0200

> While the bonding module is unloading, it is considered that after
> rtnl_link_unregister all bond devices are destroyed but since no
> synchronization mechanism exists, a new bond device can be created
> via bonding_masters before unregister_pernet_subsys which would 
> lead to multiple problems (e.g. NULL pointer dereference, wrong RIP,
> list corruption).
> 
> This patch fixes the issue by removing any bond devices left in the
> netns after bonding_masters is removed from sysfs.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
