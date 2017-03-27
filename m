From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: mpls: multipath route cleanups
Date: Mon, 27 Mar 2017 14:12:04 -0700 (PDT)
Message-ID: <20170327.141204.1008915878781461051.davem@davemloft.net>
References: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751629AbdC0VNw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 17:13:52 -0400
In-Reply-To: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 24 Mar 2017 15:21:55 -0700

> When a device associated with a nexthop is deleted, the nexthop in
> the route is effectively removed, so remove it from the route dump.
> 
> Further, when all nexhops have been deleted the route is effectively
> done, so remove the route. 

Series applied, but I agree with Roopa that you need to add that nexthop
NULL device check to lfib_nlmsg_size() too.
