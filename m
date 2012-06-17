From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] bonding: show all the link status of slaves
Date: Sun, 17 Jun 2012 16:24:11 -0700 (PDT)
Message-ID: <20120617.162411.278560789686194550.davem@davemloft.net>
References: <1339749567-20393-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab2FQXYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:24:12 -0400
In-Reply-To: <1339749567-20393-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 15 Jun 2012 16:39:27 +0800

> There are four link statuses of a bonding slave, the procfs
> code shows a wrong status when using downdelay/updelay:
> 
> 	(slave->link == BOND_LINK_UP) ?  "up" : "down"
> 
> It doesn't respect the rest two statuses. This patch fixes it.
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
