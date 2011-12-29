From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] sock_diag: Introduce the meminfo nla core
Date: Thu, 29 Dec 2011 15:05:29 -0500 (EST)
Message-ID: <20111229.150529.161850446045222440.davem@davemloft.net>
References: <4EFC754D.6000803@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab1L2UFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 15:05:36 -0500
In-Reply-To: <4EFC754D.6000803@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 29 Dec 2011 18:12:29 +0400

> Add a routine that dumps memory-related values of a socket.
> It's made as an array to make it possible to add more stuff
> here later without breaking compatibility.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

If userspace is going to need to use the SK_MEMINFO_* values, then you
need to arrange linux/sock_diag.h such that it is exportable to
userspace, and all the kernel private non-userspace exported
components are properly __KERNEL__ ifdef protected.
