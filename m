From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7 net-next-2.6] tipc: Fix race condition that could
 cause accept() to fail
Date: Mon, 14 Jul 2008 22:43:39 -0700 (PDT)
Message-ID: <20080714.224339.157245240.davem@davemloft.net>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
	<1215725171-10094-4-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60010
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754726AbYGOFnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:43:39 -0400
In-Reply-To: <1215725171-10094-4-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Thu, 10 Jul 2008 17:26:07 -0400

> This patch ensurs that accept() returns successfully even when
> the newly created socket is immediately disconnected by its peer.
> Previously, accept() would fail if it was unable to pass back
> the optional address info for the socket's peer before the
> socket became disconnected; TIPC now allows accept() to gather
> peer address information after disconnection.  As a bonus, the
> revised code accesses the socket's port more efficiently, without
> the overhead incurred by a reference table lookup.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.
