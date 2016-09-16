From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/5] cxgb4: add common api support for
 configuring filters
Date: Thu, 15 Sep 2016 20:18:04 -0400 (EDT)
Message-ID: <20160915.201804.1457345843475987771.davem@davemloft.net>
References: <cover.1473759872.git.rahul.lakkireddy@chelsio.com>
        <cover.1473759872.git.rahul.lakkireddy@chelsio.com>
        <09f7d2b95eaf850004b45a5dab48446ed6f7257f.1473759872.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: rahul.lakkireddy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756272AbcIPASK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 20:18:10 -0400
In-Reply-To: <09f7d2b95eaf850004b45a5dab48446ed6f7257f.1473759872.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Date: Tue, 13 Sep 2016 17:12:26 +0530

> +/* Fill up default masks for set match fields. */
> +static void fill_default_mask(struct ch_filter_specification *fs)
> +{
> +	unsigned int i;
> +	unsigned int lip = 0, lip_mask = 0;
> +	unsigned int fip = 0, fip_mask = 0;

Always order local variable declarations from longest to shortest
line.

Please audit your entire submission for this issue.

Thanks.
