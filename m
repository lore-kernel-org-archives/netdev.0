From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] [net] bonding: Add NUMA notice
Date: Sat, 07 Oct 2017 23:20:36 +0100 (WEST)
Message-ID: <20171007.232036.1361815658002685993.davem@davemloft.net>
References: <1507235025-21689-1-git-send-email-ptalbert@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ptalbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdJGWUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:20:53 -0400
In-Reply-To: <1507235025-21689-1-git-send-email-ptalbert@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Talbert <ptalbert@redhat.com>
Date: Thu,  5 Oct 2017 16:23:45 -0400

> Network performance can suffer when a load balancing bond uses slave
> interfaces which are in different NUMA domains.
> 
> This compares the NUMA domain of a newly enslaved interface against any
> existing enslaved interfaces and prints a warning if they do not match.
> 
> Signed-off-by: Patrick Talbert <ptalbert@redhat.com>

This is a bit over the top, and doesn't even handle cases where
the device has no specific NUMA node (-1).
