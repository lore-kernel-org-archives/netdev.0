From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Add bridge ifindex to bridge fdb
 notify msgs
Date: Mon, 02 Jun 2014 17:59:22 -0700 (PDT)
Message-ID: <20140602.175922.306402966694605258.davem@davemloft.net>
References: <1401255577-30602-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jhs@mojatatu.com, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932442AbaFCA7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:59:24 -0400
In-Reply-To: <1401255577-30602-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Tue, 27 May 2014 22:39:37 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> (This patch was previously posted as RFC at
> http://patchwork.ozlabs.org/patch/352677/)
> 
> This patch adds NDA_MASTER attribute to neighbour attributes enum for
> bridge/master ifindex. And adds NDA_MASTER to bridge fdb notify msgs.
> 
> Today bridge fdb notifications dont contain bridge information.
> Userspace can derive it from the port information in the fdb
> notification. However this is tricky in some scenarious.
> 
> Example, bridge port delete notification comes before bridge fdb
> delete notifications. And we have seen problems in userspace
> when using libnl where, the bridge fdb delete notification handling code
> does not understand which bridge this fdb entry is part of because
> the bridge and port association has already been deleted.
> And these notifications (port membership and fdb) are generated on
> separate rtnl groups.
> 
> Fixing the order of notifications could possibly solve the problem
> for some cases (I can submit a separate patch for that).
> 
> This patch chooses to add NDA_MASTER to bridge fdb notify msgs
> because it not only solves the problem described above, but also helps
> userspace avoid another lookup into link msgs to derive the master index.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
