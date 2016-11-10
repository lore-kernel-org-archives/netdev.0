From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V5 3/9] liquidio CN23XX: Mailbox support
Date: Thu, 10 Nov 2016 12:19:10 -0500 (EST)
Message-ID: <20161110.121910.154188943242358141.davem@davemloft.net>
References: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1478733232-15739-4-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@caviumnetworks.com,
        derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935590AbcKJRTN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 12:19:13 -0500
In-Reply-To: <1478733232-15739-4-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Wed, 9 Nov 2016 15:13:46 -0800

> +		dev_info(&oct->pci_dev->dev,
> +			 "PF changed VF's MAC address to %02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx\n",
> +			 mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);

We have a standard mechanism to print network addresses, including
MAC ones, via the %pXXX format specifier.  In this case you should
use "%pM" or "%pm" depending upon whether you want the address printed
with colon separators or not.
