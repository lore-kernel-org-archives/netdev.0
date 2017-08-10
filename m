From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: lower ndisc notifier priority
 below addrconf
Date: Wed, 09 Aug 2017 22:40:17 -0700 (PDT)
Message-ID: <20170809.224017.2033688992102919192.davem@davemloft.net>
References: <20170808215102.33798-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdHJFkR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:40:17 -0400
In-Reply-To: <20170808215102.33798-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Tue,  8 Aug 2017 15:51:02 -0600

> ndisc_notify is used to send unsolicited neighbor advertisements
> (e.g., on a link up). Currently, the ndisc notifier is run before the
> addrconf notifer which means NA's are not sent for link-local addresses
> which are added by the addrconf notifier.
> 
> Fix by lowering the priority of the ndisc notifier. Setting the priority
> to ADDRCONF_NOTIFY_PRIORITY - 5 means it runs after addrconf and before
> the route notifier which is ADDRCONF_NOTIFY_PRIORITY - 10.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied, thanks David.
