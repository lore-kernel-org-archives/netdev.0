From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: Allow shorthand delete of all
 nexthops in multipath route
Date: Sun, 15 Jan 2017 10:21:47 -0700
Message-ID: <e043af04-3fba-20f8-5c60-ae06166d6f7a@cumulusnetworks.com>
References: <1484351668-8962-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ddutt@cumulusnetworks.com
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34323 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdAORVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 12:21:50 -0500
Received: by mail-pf0-f177.google.com with SMTP id e4so8736019pfg.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 09:21:49 -0800 (PST)
In-Reply-To: <1484351668-8962-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/17 4:54 PM, David Ahern wrote:
> The same notation does not work with IPv6 because of how multipath routes
> are implemented for IPv6. For IPv6 only the first nexthop of a multipath
> route is deleted if the request contains only a prefix and length. This
> leads to unnecessary complexity in userspace dealing with IPv6 multipath
> routes.
> 
> This patch allows all nexthops to be deleted without specifying each one
> in the delete request

Dave: please drop this patch. I found a problem with this approach. Will re-send a new version along with some other ipv6 multipath patches.
