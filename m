From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bond_alb: do not disable BH under netpoll
Date: Tue, 03 Jan 2012 21:49:19 -0500 (EST)
Message-ID: <20120103.214919.346240095248499387.davem@davemloft.net>
References: <1325643618-3051-1-git-send-email-maxim.uvarov@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: maxim.uvarov@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab2ADCtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 21:49:24 -0500
In-Reply-To: <1325643618-3051-1-git-send-email-maxim.uvarov@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxim Uvarov <maxim.uvarov@oracle.com>
Date: Tue,  3 Jan 2012 18:20:18 -0800

> Do not disable BH if interrupts are already disabled
> (netpoll case).
> Signed-off-by: Maxim Uvarov <maxim.uvarov@oracle.com>

Barf...

We should never use conditional locking like this.
