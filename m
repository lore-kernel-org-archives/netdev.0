From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bridge: Do not unregister all PF_BRIDGE rtnl
 operations
Date: Wed, 19 Dec 2012 12:50:48 -0800 (PST)
Message-ID: <20121219.125048.1590630816104658477.davem@davemloft.net>
References: <1355944428-32051-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab2LSUut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:50:49 -0500
In-Reply-To: <1355944428-32051-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 19 Dec 2012 14:13:48 -0500

> Bridge fdb and link rtnl operations are registered in
> core/rtnetlink.  Bridge mdb operations are registred
> in bridge/mdb.  When removing bridge module, do not
> unregister ALL PF_BRIDGE ops since that would remove
> the ops from rtnetlink as well.  Do remove mdb ops when
> bridge is destroyed.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied.
