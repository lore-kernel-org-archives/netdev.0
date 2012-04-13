From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] l2tp: l2tp_ip socket fixes
Date: Fri, 13 Apr 2012 11:06:45 -0400 (EDT)
Message-ID: <20120413.110645.2101243409451679048.davem@davemloft.net>
References: <1334052643-10910-1-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab2DMPGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 11:06:53 -0400
In-Reply-To: <1334052643-10910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 10 Apr 2012 11:10:41 +0100

> A couple of small fixes for the l2tp_ip socket support. This is for
> L2TPv3 IP link encapsulation.
> 
> [PATCH 1/2] l2tp: fix refcount leak in l2tp_ip sockets
> [PATCH 2/2] l2tp: don't overwrite source address in l2tp_ip_bind()

Both applied, although I hope patch #2 doesn't unintentionally break
things for someone.  It's not unreasonable to think that someone may
be depending upon that saddr being set to INADDR_ANY in that case
you're changing.
