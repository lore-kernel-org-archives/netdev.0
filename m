From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2][BUG-FIX] dccp: two bug-fixes
Date: Sat, 03 Mar 2012 14:57:24 -0500 (EST)
Message-ID: <20120303.145724.979579867935018033.davem@davemloft.net>
References: <test_tree_patch_set_update_2012-03-03>
	<1330792433-15415-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752992Ab2CCT63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 14:58:29 -0500
In-Reply-To: <1330792433-15415-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat,  3 Mar 2012 09:33:51 -0700

> please find attached two bug fix patches for DCCP.  
> 
>  Patch #1: removes a BUG_ON which got triggered under normal operational conditions,
>            found that it is not even necessary, hence replaced;
>  Patch #2: fixes sequence number handling during initial connection setup, ensuring
>            connection establishment even if one or more initial Request(s) get lost.
> 
> The patches are also available applied on top of today's net-next, at
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next  [subtree 'dccp']
> 
> All patches have been tested and compile independently.

Pulled, thanks a lot Gerrit.
