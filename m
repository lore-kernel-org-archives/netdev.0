From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] 6lowpan: fragmentation fixes
Date: Mon, 02 Jun 2014 10:40:25 -0700 (PDT)
Message-ID: <20140602.104025.2073329000274245328.davem@davemloft.net>
References: <1401708118-16436-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de, werner@almesberger.net
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaFBRk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 13:40:27 -0400
In-Reply-To: <1401708118-16436-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Mon,  2 Jun 2014 13:21:56 +0200

> This patch series fix the 6LoWPAN fragmentation which are in two cases broken.
> 
> The first case is if we have exactly two 6LoWPAN fragments only. This is fixed
> by patch "6lowpan_rtnl: fix fragmentation with two fragments".
> The second case is a off by one issue if we have payload which hits the fragment
> boundary.
> 
> Both issues are introduced by commit d4b2816d67d6e07b2f27037f282d8db03a5829d7
> ("6lowpan: fix fragmentation").

Series applied, thanks Alexander.
