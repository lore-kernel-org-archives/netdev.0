From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel: update mtu properly for ARPHRD_ETHER
 tunnel device in tx path
Date: Sun, 01 Oct 2017 03:55:03 +0100 (WEST)
Message-ID: <20171001.035503.103605557238471886.davem@davemloft.net>
References: <f4105462b42f560a0aaace0be3e66129200bdf29.1506576247.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdJACzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 22:55:04 -0400
In-Reply-To: <f4105462b42f560a0aaace0be3e66129200bdf29.1506576247.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 28 Sep 2017 13:24:07 +0800

> Now when updating mtu in tx path, it doesn't consider ARPHRD_ETHER tunnel
> device, like ip6gre_tap tunnel, for which it should also subtract ether
> header to get the correct mtu.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
