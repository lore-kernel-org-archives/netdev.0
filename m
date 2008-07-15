From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7 net-next-2.6] tipc: Fix bug in scope checking for
 multicast messages
Date: Mon, 14 Jul 2008 22:44:39 -0700 (PDT)
Message-ID: <20080714.224439.246166003.davem@davemloft.net>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
	<1215725171-10094-6-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752989AbYGOFoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:44:38 -0400
In-Reply-To: <1215725171-10094-6-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu, 10 Jul 2008 17:26:09 -0400

> This patch ensures that TIPC's multicast message name lookup
> algorithm does individualized scope checking for each published
> name it examines.  Previously, scope checking was only done for
> the first name in a name table publication list, which could
> result in incoming multicast messages being delivered to ports
> publishing names with "node" scope, or not being delivered to
> ports publishing names with "cluster" or "zone" scope.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
