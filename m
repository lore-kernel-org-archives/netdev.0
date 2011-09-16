From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: deal with multiple COOKIE_ECHO chunks
Date: Fri, 16 Sep 2011 17:17:47 -0400 (EDT)
Message-ID: <20110916.171747.406895441960738806.davem@davemloft.net>
References: <20110830072010.94AE98132707@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com
To: makc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab1IPVSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 17:18:03 -0400
In-Reply-To: <20110830072010.94AE98132707@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Matveev <makc@redhat.com>
Date: Tue, 30 Aug 2011 17:02:24 +1000

> Attempt to reduce the number of IP packets emitted in response to single
> SCTP packet (2e3216cd) introduced a complication - if a packet contains
> two COOKIE_ECHO chunks and nothing else then SCTP state machine corks the
> socket while processing first COOKIE_ECHO and then loses the association
> and forgets to uncork the socket. To deal with the issue add new SCTP
> command which can be used to set association explictly. Use this new
> command when processing second COOKIE_ECHO chunk to restore the context
> for SCTP state machine.
> 
> Signed-off-by: Max Matveev <makc@redhat.com>

Applied, but there were a ton of whitespace errors that GIT complained
about and I had to fix up.
