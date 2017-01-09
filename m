From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/appletalk: Fix kernel memory disclosure
Date: Mon, 09 Jan 2017 16:38:52 -0500 (EST)
Message-ID: <20170109.163852.1282623434902640995.davem@davemloft.net>
References: <1483970268-6145-1-git-send-email-vlad@tsyrklevich.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: vlad@tsyrklevich.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51772 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937102AbdAIVix (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:38:53 -0500
In-Reply-To: <1483970268-6145-1-git-send-email-vlad@tsyrklevich.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Date: Mon,  9 Jan 2017 20:57:48 +0700

> ipddp_route structs contain alignment padding so kernel heap memory
> is leaked when they are copied to user space in
> ipddp_ioctl(SIOCFINDIPDDPRT). Change kmalloc() to kzalloc() to clear
> that memory.
> 
> Signed-off-by: Vlad Tsyrklevich <vlad@tsyrklevich.net>

Applied.
