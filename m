From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] net: extend RTM_GETROUTE to return fib
 result
Date: Fri, 26 May 2017 14:18:38 -0400 (EDT)
Message-ID: <20170526.141838.790479821297151569.davem@davemloft.net>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, rami.rosen@intel.com, netdev@vger.kernel.org,
        nikolay@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948537AbdEZSSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:18:43 -0400
In-Reply-To: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Thu, 25 May 2017 10:42:32 -0700

> This series adds a new RTM_F_FIB_MATCH flag to return matched fib result
> with RTM_GETROUTE. This is useful for applications and protocols in
> userspace wanting to query the selected route.

Looks good, series applied, thanks.

Have you considered taking this further and allowing one to see which
nexthop a route lookup picked?
