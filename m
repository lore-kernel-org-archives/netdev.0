From: David Miller <davem@davemloft.net>
Subject: Re: [REPOST][GENETLINK]: Fix race in genl_unregister_mc_groups()
Date: Tue, 24 Jul 2007 15:32:58 -0700 (PDT)
Message-ID: <20070724.153258.130239559.davem@davemloft.net>
References: <20070724094557.GE9285@postel.suug.ch>
	<20070724215257.GG9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33963
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755905AbXGXWc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 18:32:59 -0400
In-Reply-To: <20070724215257.GG9285@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 24 Jul 2007 23:52:57 +0200

> family->mcast_groups is protected by genl_lock so it must
> be held while accessing the list in genl_unregister_mc_groups().
> Requires adding a non-locking variant of genl_unregister_mc_group().
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
