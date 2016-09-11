From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] liquidio CN23XX: Mailbox support
Date: Sat, 10 Sep 2016 21:42:01 -0700 (PDT)
Message-ID: <20160910.214201.116857018916997521.davem@davemloft.net>
References: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1473451707-26397-4-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbcIKEmD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 00:42:03 -0400
In-Reply-To: <1473451707-26397-4-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Fri, 9 Sep 2016 13:08:25 -0700

> +int octeon_mbox_read(struct octeon_mbox *mbox)
> +{
> +	int ret = 0;
> +	union octeon_mbox_message msg;
> +

Please always order local variable declarations from longest
to shortest line.

Please audit your entire submission for this problem.
