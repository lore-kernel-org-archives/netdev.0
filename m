From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/7] liquidio CN23XX: VF scatter gather lists
Date: Mon, 05 Dec 2016 19:48:32 -0500 (EST)
Message-ID: <20161205.194832.1102997695171872315.davem@davemloft.net>
References: <1480929318-8511-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1480929318-8511-5-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@caviumnetworks.com,
        derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbcLFAse (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 19:48:34 -0500
In-Reply-To: <1480929318-8511-5-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Mon, 5 Dec 2016 01:15:15 -0800

> +	kfree((void *)lio->glist);
> +	kfree((void *)lio->glist_lock);
> +}
 ...
> +	if (!lio->glist) {
> +		kfree((void *)lio->glist_lock);
> +		return 1;
> +	}

These void casts are unnecessary, please remove them.
