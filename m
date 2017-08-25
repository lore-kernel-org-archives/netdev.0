From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Route ICMPv6 errors with the flow when
 ECMP in use
Date: Thu, 24 Aug 2017 18:21:42 -0700 (PDT)
Message-ID: <20170824.182142.290308098201695789.davem@davemloft.net>
References: <20170823075831.27031-1-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        nikolay@cumulusnetworks.com, tom@herbertland.com
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753924AbdHYBVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:21:43 -0400
In-Reply-To: <20170823075831.27031-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Wed, 23 Aug 2017 09:58:27 +0200

> This patch set is another take at making Path MTU Discovery work when
> server nodes are behind a router employing multipath routing in a
> load-balance or anycast setup (that is, when not every end-node can be
> reached by every path). The problem has been well described in RFC 7690
> [1], but in short - in such setups ICMPv6 PTB errors are not guaranteed
> to be routed back to the server node that sent a reply that exceeds path
> MTU.
 ...

Ok, looks not to bad.

Applied, thanks.
