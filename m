From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] netconf: Add support for RTM_DELNETCONF
Date: Tue, 28 Mar 2017 22:32:57 -0700 (PDT)
Message-ID: <20170328.223257.1804803147939889749.davem@davemloft.net>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbdC2FdE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:33:04 -0400
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 28 Mar 2017 14:28:00 -0700

> netconf notifications are sent as devices register but not when they
> are deleted leaving userspace caches out of sync. Add support for
> RTM_DELNETCONF to ipv4, ipv6 and mpls.
> 
> MPLS is missing RTM_NEWNETCONF as devices are created, so add it as well.

Series applied, thanks.
