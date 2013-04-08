From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert "bonding: remove sysfs before removing
 devices"
Date: Mon, 08 Apr 2013 16:45:21 -0400 (EDT)
Message-ID: <20130408.164521.1604747318872514349.davem@davemloft.net>
References: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762581Ab3DHUpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:45:23 -0400
In-Reply-To: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat,  6 Apr 2013 12:54:37 +0200

> This reverts commit 4de79c737b200492195ebc54a887075327e1ec1d.
> 
> This patch introduces a new bug which causes access to freed memory.
> In bond_uninit: list_del(&bond->bond_list);
> bond_list is linked in bond_net's dev_list which is freed by
> unregister_pernet_subsys.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
