From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/7] Reduce cache miss for snmp_fold_field
Date: Fri, 30 Sep 2016 02:14:02 -0400 (EDT)
Message-ID: <20160930.021402.267441690910051825.davem@davemloft.net>
References: <1475206144-23228-1-git-send-email-hejianet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        vyasevich@gmail.com, nhorman@tuxdriver.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        marcelo.leitner@gmail.com
To: hejianet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935642AbcI3GOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 02:14:09 -0400
In-Reply-To: <1475206144-23228-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia He <hejianet@gmail.com>
Date: Fri, 30 Sep 2016 11:28:57 +0800

> In a PowerPc server with large cpu number(160), besides commit
> a3a773726c9f ("net: Optimize snmp stat aggregation by walking all
> the percpu data at once"), I watched several other snmp_fold_field
> callsites which would cause high cache miss rate.
 ...

Series applied, thank you.
