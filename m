From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/3] bna: Semaphore Lock Fix
Date: Sat, 17 Sep 2011 00:48:08 -0400 (EDT)
Message-ID: <20110917.004808.171529275837110784.davem@davemloft.net>
References: <1316221608-21392-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	gkaraje@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1IQEtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 00:49:11 -0400
In-Reply-To: <1316221608-21392-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Fri, 16 Sep 2011 18:06:46 -0700

> Remove a BUG_ON() as it is not required.
> 
> Change the unconditional write to release a semaphore to read sem first
> and then write. This will eliminate the possibility of sem getting locked
> while trying to release it in case if previous sem_get operation failed.
> 
> Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied.
