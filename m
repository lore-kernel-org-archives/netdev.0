From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: free the mac filter group list before
 freeing the cmd
Date: Tue, 27 Sep 2016 09:55:43 -0400 (EDT)
Message-ID: <20160927.095543.226018681879639981.davem@davemloft.net>
References: <1474902044-16742-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        netdev@vger.kernel.org
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755115AbcI0Nzr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 09:55:47 -0400
In-Reply-To: <1474902044-16742-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Mon, 26 Sep 2016 11:00:44 -0400

> The group list must be freed prior to freeing the command otherwise
> we have a use-after-free.
> 
> Signed-off-by: Jason Baron <jbaron@akamai.com>

Applied, thanks for the quick fixup Jason.
