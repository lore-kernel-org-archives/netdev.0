From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] loopback: Force LOOPBACK_IFINDEX for registration
Date: Mon, 19 Jun 2017 14:41:23 -0400 (EDT)
Message-ID: <20170619.144123.2070662074449196481.davem@davemloft.net>
References: <1497615003-24762-1-git-send-email-serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36840 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbdFSSlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:41:25 -0400
In-Reply-To: <1497615003-24762-1-git-send-email-serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Fri, 16 Jun 2017 15:10:03 +0300

> Now with commit 9c7dafb (net: Allow to create links with
> given ifindex) support registration of network devices
> with specific ifindex is added.
> 
> We can force loopback network device index before call to
> register_netdev() to ensure we always configure it with
> LOOPBACK_IFINDEX.
> 
> Kill BUG_ON() since system can continue without network
> namespace failed in loopback init path, unless it is
> init_net namespace where we panic() anyway.
> 
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>

Is the BUG_ON() triggering, if so why?

It looks to me that unless there is a bug, this assignment
is unnecessary.
