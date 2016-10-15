From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Require exact match for TCP socket lookups if
 dif is l3mdev
Date: Sat, 15 Oct 2016 19:32:36 -0400 (EDT)
Message-ID: <20161015.193236.1802271946749974666.davem@davemloft.net>
References: <1476473359-15422-1-git-send-email-dsa@cumulusnetworks.com>
        <20161015.174654.72392403309705041.davem@davemloft.net>
        <48ba7600-0624-9684-e609-b7a315e03483@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752604AbcJOXco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 19:32:44 -0400
In-Reply-To: <48ba7600-0624-9684-e609-b7a315e03483@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 15 Oct 2016 17:07:53 -0600

> I believe at netconf someone mentioned it would be a great day when
> something is done for IPv6 first and IPv4 was a follow on. Here you
> go. :-)

:-)

> I can rename the existing one to skb_l3mdev_slave_6 and make the new
> one skb_l3mdev_slave_4.

That works.  So does names with "ipv4_" and "ipv6_" prefixes which at
least to me seems more canonical.  But maybe I'm just weird like that.
