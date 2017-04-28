From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netvsc: make sure napi enabled before vmbus_open
Date: Fri, 28 Apr 2017 16:09:13 -0400 (EDT)
Message-ID: <20170428.160913.1378797538282359486.davem@davemloft.net>
References: <20170426235830.14801-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642596AbdD1UJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 16:09:14 -0400
In-Reply-To: <20170426235830.14801-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 26 Apr 2017 16:58:30 -0700

> This fixes a race where vmbus callback for new packet arriving
> could occur before NAPI is initialized. Happens more on WS2008
> which takes longer to setup channel.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

This doesn't apply cleanly to 'net'.
