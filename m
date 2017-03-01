From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net/ipv6] net/ipv6: avoid possible dead locking on
 addr_gen_mode sysctl
Date: Wed, 01 Mar 2017 13:24:42 -0500 (EST)
Message-ID: <20170301.132442.1331801761085806178.davem@davemloft.net>
References: <20170226234123.18713-1-felix.jia@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: felix.jia@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdCASYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 13:24:43 -0500
In-Reply-To: <20170226234123.18713-1-felix.jia@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Jia <felix.jia@alliedtelesis.co.nz>
Date: Mon, 27 Feb 2017 12:41:23 +1300

> The addr_gen_mode variable can be accessed by both sysctl and netlink.
> Repleacd rtnl_lock() with rtnl_trylock() protect the sysctl operation to
> avoid the possbile dead lock.`
> 
> Signed-off-by: Felix Jia <felix.jia@alliedtelesis.co.nz>

Applied and queued up for -stable, thanks.
