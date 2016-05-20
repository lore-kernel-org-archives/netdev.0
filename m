From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] RDS: TCP: connection spamming fixes
Date: Fri, 20 May 2016 19:20:32 -0400 (EDT)
Message-ID: <20160520.192032.1207007536147387597.davem@davemloft.net>
References: <cover.1463579486.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbcETXUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:20:36 -0400
In-Reply-To: <cover.1463579486.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 18 May 2016 10:06:22 -0700

> We have been testing the RDS-TCP code with a connection spammer
> that sends incoming SYNs to the RDS listen port well after 
> an rds-tcp connection has been established, and found a few 
> race-windows that are fixed by this patch series.
> 
> Patch 1 avoids a null pointer deref when an incoming SYN 
> shows up when a netns is being dismantled, or when the 
> rds-tcp module is being unloaded. 
> 
> Patch 2 addresses the case when a SYN is received after the
> connection arbitration algorithm has converged: the incoming
> SYN should not needlessly quiesce the transmit path, and it
> should not result in needless TCP connection resets due to
> re-execution of the connection arbitration logic.

Series applied, thanks.
