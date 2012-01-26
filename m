From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: bind() fix autoselection to share ports
Date: Wed, 25 Jan 2012 21:50:58 -0500 (EST)
Message-ID: <20120125.215058.2275010901894362445.davem@davemloft.net>
References: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com, eric.dumazet@gmail.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab2AZCvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 21:51:03 -0500
In-Reply-To: <1327516492-9045-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 25 Jan 2012 16:34:51 -0200

> The current code checks for conflicts when the application
> requests a specific port.  If there is no conflict, then
> the request is granted.
> 
> On the other hand, the port autoselection done by the kernel
> fails when all ports are bound even when there is a port
> with no conflict available.
> 
> The fix changes port autoselection to check if there is a
> conflict and use it if not.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied.
