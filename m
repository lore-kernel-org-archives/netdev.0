From: Max Matveev <makc@redhat.com>
Subject: Re: [PATCH] sctp: deal with multiple COOKIE_ECHO chunks
Date: Sat, 17 Sep 2011 14:38:27 +1000
Message-ID: <20084.9283.714998.398630@regina.usersys.redhat.com>
References: <20110830072010.94AE98132707@regina.usersys.redhat.com>
	<20110916.171747.406895441960738806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772Ab1IQEin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Sep 2011 00:38:43 -0400
In-Reply-To: <20110916.171747.406895441960738806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Sep 2011 17:17:47 -0400 (EDT), David Miller wrote:

 davem> From: Max Matveev <makc@redhat.com>
 davem> Date: Tue, 30 Aug 2011 17:02:24 +1000

 >> Attempt to reduce the number of IP packets emitted in response to single
 >> SCTP packet (2e3216cd) introduced a complication - if a packet contains
 >> two COOKIE_ECHO chunks and nothing else then SCTP state machine corks the
 >> socket while processing first COOKIE_ECHO and then loses the association
 >> and forgets to uncork the socket. To deal with the issue add new SCTP
 >> command which can be used to set association explictly. Use this new
 >> command when processing second COOKIE_ECHO chunk to restore the context
 >> for SCTP state machine.
 >> 
 >> Signed-off-by: Max Matveev <makc@redhat.com>

 davem> Applied, but there were a ton of whitespace errors that GIT complained
 davem> about and I had to fix up.

Sorry about it - I did check it with checkpatch.pl and it was happy:
must've been the mailer.

max
