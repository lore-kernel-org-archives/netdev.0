From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: put host and anycast routes on
 device with address
Date: Thu, 17 Aug 2017 10:31:06 -0700 (PDT)
Message-ID: <20170817.103106.1225843002248604353.davem@davemloft.net>
References: <1502923076-12292-1-git-send-email-dsahern@gmail.com>
        <3b4eb556-a25b-75a8-9d29-1974607044cf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
        hannes@stressinduktion.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752270AbdHQRbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:31:07 -0400
In-Reply-To: <3b4eb556-a25b-75a8-9d29-1974607044cf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 17 Aug 2017 10:56:54 -0600

> DaveM: please drop this one. I found a use case that is failing: UDP
> packets to a local linklocal address with no server are not getting the
> ICMP unreachable. Will send a v2 when tests complete.

Ok.
