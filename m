From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mpls: Send route delete notifications when router
 module is unloaded
Date: Sun, 12 Mar 2017 23:40:19 -0700 (PDT)
Message-ID: <20170312.234019.2178953006416512452.davem@davemloft.net>
References: <1489167975-11729-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
        roopa@cumulusnetworks.com, rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdCMGto (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:49:44 -0400
In-Reply-To: <1489167975-11729-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 10 Mar 2017 09:46:15 -0800

> When the mpls_router module is unloaded, mpls routes are deleted but
> notifications are not sent to userspace leaving userspace caches
> out of sync. Add the call to mpls_notify_route in mpls_net_exit as
> routes are freed.
> 
> Fixes: 0189197f44160 ("mpls: Basic routing support")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable.
