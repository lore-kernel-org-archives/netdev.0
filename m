From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the origin tree
Date: Sun, 13 May 2012 23:00:26 -0400 (EDT)
Message-ID: <20120513.230026.1170494017599992321.davem@davemloft.net>
References: <20120514104452.2411b761e8f98076d1ae88ee@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	jbohac@suse.cz
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab2ENDDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2012 23:03:05 -0400
In-Reply-To: <20120514104452.2411b761e8f98076d1ae88ee@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 14 May 2012 10:44:52 +1000

> Introduced by commit 13a8e0c8cdb4 ("bonding: don't increase rx_dropped
> after processing LACPDUs"). recv-probe in struct bonding is a function
> returning void, but the local variable it assigned to/from has been
> changed to a function returning int ...

http://marc.info/?l=linux-netdev&m=133693883404392&w=2
