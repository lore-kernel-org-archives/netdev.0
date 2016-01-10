From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/2] tipc: move netlink policies to
 netlink.h
Date: Sat, 09 Jan 2016 21:03:30 -0500 (EST)
Message-ID: <20160109.210330.1628988129816325757.davem@davemloft.net>
References: <1451987777-17421-1-git-send-email-richard.alpe@ericsson.com>
	<20160105.164749.1356932343853770417.davem@davemloft.net>
	<568E3BD8.8040209@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613AbcAJCDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 21:03:32 -0500
In-Reply-To: <568E3BD8.8040209@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Thu, 7 Jan 2016 11:20:08 +0100

> Do you have any suggestion on how to handle the case where a policy
> (table) is shared between c files, like the net policy in the
> subsequent patch? I could perhaps use extern in the c files (which
> seems frown upon) or duplicate the policy? :-S

Probably you'll need to instantiate it in one source file, and export
it for the others to use.
