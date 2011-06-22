From: David Miller <davem@davemloft.net>
Subject: net-2.6 GIT rolled back 3 commits...
Date: Tue, 21 Jun 2011 22:36:43 -0700 (PDT)
Message-ID: <20110621.223643.1639490880583883623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724Ab1FVFix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 01:38:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I had to roll back the net-2.6 GIT tree by three commits to get
rid of the buggy UDP uhash_entries patch.

You can easily fix your tree by going:

git reset --hard 58fa45973117ab7a79d5b6818275a887867fc4d7

and then re-pulling.

Sorry for the inconvenience this may cause.
