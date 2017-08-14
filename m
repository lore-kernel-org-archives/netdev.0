From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 8/8] liquidio: added support for ethtool
 --set-ring feature
Date: Sun, 13 Aug 2017 19:43:15 -0700 (PDT)
Message-ID: <20170813.194315.2299024672935275105.davem@davemloft.net>
References: <20170812012818.GA2505@felix-thinkpad.cavium.com>
        <20170812012930.GA2614@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752061AbdHNCnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 22:43:18 -0400
In-Reply-To: <20170812012930.GA2614@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 11 Aug 2017 18:29:30 -0700

> +	if ((ering->rx_mini_pending) || (ering->rx_jumbo_pending))
> +		return -EINVAL;

Lots of unnecessary parenthesis, please remove.

> +	if ((rx_count == rx_count_old) && (tx_count == tx_count_old))
> +		return 0;

Likewise.
