From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: make sure napi enabled before vmbus_open
Date: Thu, 04 May 2017 11:08:53 -0400 (EDT)
Message-ID: <20170504.110853.2300193499854196980.davem@davemloft.net>
References: <20170503235921.31407-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753490AbdEDPIy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 11:08:54 -0400
In-Reply-To: <20170503235921.31407-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed,  3 May 2017 16:59:21 -0700

> This fixes a race where vmbus callback for new packet arriving
> could occur before NAPI is initialized.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks Stephen.
