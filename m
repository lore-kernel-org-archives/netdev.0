From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/4] net: dsa: Multi-CPU ground work (v4)
Date: Tue, 13 Jun 2017 16:35:42 -0400 (EDT)
Message-ID: <20170613.163542.1408709625950662812.davem@davemloft.net>
References: <20170613202722.17598-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753311AbdFMUfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:35:44 -0400
In-Reply-To: <20170613202722.17598-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 13 Jun 2017 13:27:18 -0700

> This patch series prepares the ground for adding mutliple CPU port support to
> DSA, and starts by removing redundant pieces of information such as
> master_netdev which is cpu_dp->ethernet. Finally drivers are moved away from
> directly accessing ds->dst->cpu_dp and use appropriate helper functions.
> 
> Note that if you have Device Tree blobs/platform configurations that are
> currently listing multiple CPU ports, the proposed behavior in
> dsa_ds_get_cpu_dp() will be to return the last bit set in ds->cpu_port_mask.
> 
> Future plans include:
> - making dst->cpu_dp a flexible data structure (array, list, you name it)
> - having the ability for drivers to return a default/preferred CPU port (if
>   necessary)
> 
> Changes in v4:
> 
> - fixed build warning with NETPOLL enabled
 ...

Applied, thanks for the quick respin.
