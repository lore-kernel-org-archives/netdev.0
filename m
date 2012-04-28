From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] drop_monitor: misc fixes for some recently
 reported bugs
Date: Sat, 28 Apr 2012 02:19:42 -0400 (EDT)
Message-ID: <20120428.021942.277308620051159090.davem@davemloft.net>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
	<1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab2D1GUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 02:20:51 -0400
In-Reply-To: <1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 27 Apr 2012 16:11:47 -0400

>         Eric was using dropwatch recently and reported a few bugs to me that he
> had noted.  This short series should fix them all up.
> 
> Change Notes:
> V2)
> 	renamed trace_state_lock to trace_state_mutex
> 	cleaned up rcu write side access to use rcu_dereference_protected
> 	handled some NULL allocation failure cases

Both applied, but in the second patch I had to fix the spelling
of the "initialized" variable :-)

Thanks Neil.
