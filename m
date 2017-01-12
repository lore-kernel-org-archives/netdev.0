From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: fix table id in getroute response
Date: Thu, 12 Jan 2017 15:18:36 -0500 (EST)
Message-ID: <20170112.151836.288062594944589718.davem@davemloft.net>
References: <1484178137-23735-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdALUSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:18:38 -0500
In-Reply-To: <1484178137-23735-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 11 Jan 2017 15:42:17 -0800

> rtm_table is an 8-bit field while table ids are allowed up to u32. Commit
> 709772e6e065 ("net: Fix routing tables with id > 255 for legacy software")
> added the preference to set rtm_table in dumps to RT_TABLE_COMPAT if the
> table id is > 255. The table id returned on get route requests should do
> the same.
> 
> Fixes: c36ba6603a11 ("net: Allow user to get table id from route lookup")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Good catch, applied and queued up for -stable.
