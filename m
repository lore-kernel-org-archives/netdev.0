From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/9] tcpnv: do not export local function
Date: Sun, 21 May 2017 13:43:36 -0400 (EDT)
Message-ID: <20170521.134336.1250521298948022498.davem@davemloft.net>
References: <20170519165556.483-1-sthemmin@microsoft.com>
        <20170519165556.483-6-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756582AbdEURni (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:43:38 -0400
In-Reply-To: <20170519165556.483-6-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 19 May 2017 09:55:52 -0700

> The TCP New Vegas congestion control was exporting an internal
> function tcpnv_get_info which is not used by any other in tree
> kernel code. Make it static.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
