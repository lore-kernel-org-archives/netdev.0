From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bonding: properly unset current_arp_slave on slave
 link up
Date: Thu, 05 Apr 2012 19:08:38 -0400 (EDT)
Message-ID: <20120405.190838.33439049975921271.davem@davemloft.net>
References: <20120405134743.GB16870@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab2DEXIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 19:08:46 -0400
In-Reply-To: <20120405134743.GB16870@darkmag.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Thu, 5 Apr 2012 15:47:43 +0200

> When a slave comes up, we're unsetting the current_arp_slave without
> removing active flags from it, which can lead to situations where we have
> more than one slave with active flags in active-backup mode.
> 
> To avoid this situation we must remove the active flags from a slave before
> removing it as a current_arp_slave.
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Applied, thanks.
