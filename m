From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: bind() optimize port allocation
Date: Wed, 25 Jan 2012 21:51:07 -0500 (EST)
Message-ID: <20120125.215107.1691418905626057552.davem@davemloft.net>
References: <1327516492-9045-1-git-send-email-fbl@redhat.com>
	<1327516492-9045-2-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com, eric.dumazet@gmail.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607Ab2AZCvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 21:51:11 -0500
In-Reply-To: <1327516492-9045-2-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 25 Jan 2012 16:34:52 -0200

> Port autoselection finds a port and then drop the lock,
> then right after that, gets the hash bucket again and lock it.
> 
> Fix it to go direct.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied, great work Flavio.
