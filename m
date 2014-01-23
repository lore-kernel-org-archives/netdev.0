From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net/cxgb4: Don't retrieve stats during recovery
Date: Thu, 23 Jan 2014 13:21:37 -0800 (PST)
Message-ID: <20140123.132137.1896222826457322803.davem@davemloft.net>
References: <1390451256-11486-1-git-send-email-shangw@linux.vnet.ibm.com>
	<1390451256-11486-2-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com, ben@decadent.org.uk
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbaAWVVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:21:38 -0500
In-Reply-To: <1390451256-11486-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Thu, 23 Jan 2014 12:27:35 +0800

> We possibly retrieve the adapter's statistics during EEH recovery
> and that should be disallowed. Otherwise, it would possibly incur
> replicate EEH error and EEH recovery is going to fail eventually.
> 
> The patch reuses statistics lock and checks net_device is attached
> before going to retrieve statistics, so that the problem can be
> avoided.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Applied.
