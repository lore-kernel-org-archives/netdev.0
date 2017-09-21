From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v3] bridge: trigger RTM_NEWLINK when interface is
 modified by bridge ioctl
Date: Thu, 21 Sep 2017 15:45:32 -0700 (PDT)
Message-ID: <20170921.154532.1965889647748557919.davem@davemloft.net>
References: <20170920162140.369bb198@xeon-e3>
        <20170921100525.20395-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, dsahern@gmail.com,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:45:33 -0400
In-Reply-To: <20170921100525.20395-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <vincent@bernat.im>
Date: Thu, 21 Sep 2017 12:05:25 +0200

> Currently, there is a difference in netlink events received when an
> interface is modified through bridge ioctl() or through netlink. This
> patch generates additional events when an interface is added to or
> removed from a bridge via ioctl().
...
> Signed-off-by: Vincent Bernat <vincent@bernat.im>

Applied.
