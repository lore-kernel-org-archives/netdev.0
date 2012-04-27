From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: bond_update_speed_duplex() can
 return void since no callers check its return
Date: Fri, 27 Apr 2012 00:04:31 -0400 (EDT)
Message-ID: <20120427.000431.275079983903950298.davem@davemloft.net>
References: <20120426212030.269072900341@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: rick.jones2@hp.com, raj@tardy.cup.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab2D0EGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 00:06:48 -0400
In-Reply-To: <20120426212030.269072900341@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.cup.hp.com (Rick Jones)
Date: Thu, 26 Apr 2012 14:20:30 -0700 (PDT)

> From: Rick Jones <rick.jones2@hp.com>
> 
> As none of the callers of bond_update_speed_duplex (need to) check its
> return value, there is little point in it returning anything.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied.
