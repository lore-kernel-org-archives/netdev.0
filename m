From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] unix_diag: Fixup RQLEN extension report
Date: Fri, 30 Dec 2011 16:47:38 -0500 (EST)
Message-ID: <20111230.164738.1765211576870701484.davem@davemloft.net>
References: <4EFD986F.4030808@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab1L3Vrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 16:47:42 -0500
In-Reply-To: <4EFD986F.4030808@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 30 Dec 2011 14:54:39 +0400

> While it's not too late fix the recently added RQLEN diag extension
> to report rqlen and wqlen in the same way as TCP does.
> 
> I.e. for listening sockets the ack backlog length (which is the input
> queue length for socket) in rqlen and the max ack backlog length in
> wqlen, and what the CINQ/OUTQ ioctls do for established.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
