From: David Miller <davem@davemloft.net>
Subject: Re: [B.A.T.M.A.N.] pull request: batman-adv 2011-09-08
Date: Wed, 21 Sep 2011 20:11:53 -0400 (EDT)
Message-ID: <20110921.201153.1030355996800820632.davem@davemloft.net>
References: <201109220139.26897.lindner_marek@yahoo.de>
	<20110921.200539.1422752575190292433.davem@davemloft.net>
	<201109220210.05025.lindner_marek@yahoo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: lindner_marek@yahoo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab1IVAM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 20:12:57 -0400
In-Reply-To: <201109220210.05025.lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>
Date: Thu, 22 Sep 2011 02:10:04 +0200

> No, the data structures for the routing lookups remain the same but there will 
> be more than one way to fill them with data. You will only use one "filling 
> algorithm" at a time, so you will need to select the one you want.

Extend the userspace interface for adding route entries with a boolean
flag.  You're using netlink right?  If so, this should be trivial by
simply adding a flags attribute if you don't have one already.
