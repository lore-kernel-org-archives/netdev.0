From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] neigh: Really delete an arp/neigh entry on
 "ip neigh delete" or "arp -d"
Date: Wed, 31 May 2017 14:21:13 -0400 (EDT)
Message-ID: <20170531.142113.663711787657155712.davem@davemloft.net>
References: <1496179897-82646-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdEaSVZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:21:25 -0400
In-Reply-To: <1496179897-82646-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 30 May 2017 14:31:37 -0700

> +EXPORT_SYMBOL(neigh_remove_one);

net/ipv4/arp.c is the only reference you add to this symbol and ipv4
cannot be built modular.

So this export is unnecessary.
