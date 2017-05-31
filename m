From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: fix clearing of dead nh_flags on link up
Date: Wed, 31 May 2017 14:48:56 -0400 (EDT)
Message-ID: <20170531.144856.880932111102757306.davem@davemloft.net>
References: <1496213436-33961-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdEaSs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:48:57 -0400
In-Reply-To: <1496213436-33961-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 30 May 2017 23:50:36 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> recent fixes to use WRITE_ONCE for nh_flags on link up,
> accidently ended up leaving the deadflags on a nh. This patch
> fixes the WRITE_ONCE to use freshly evaluated nh_flags.
> 
> Fixes: 39eb8cd17588 ("net: mpls: rt_nhn_alive and nh_flags should be accessed using READ_ONCE")
> Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
