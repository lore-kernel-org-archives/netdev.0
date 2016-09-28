From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 0/6] fib offload: switch to notifier
Date: Wed, 28 Sep 2016 04:49:30 -0400 (EDT)
Message-ID: <20160928.044930.430080084052194610.davem@davemloft.net>
References: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbcI1Itl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 04:49:41 -0400
In-Reply-To: <1474887154-6286-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 26 Sep 2016 12:52:28 +0200

> The goal of this patchset is to allow driver to propagate all prefixes
> configured in kernel down HW. This is necessary for routing to work
> as expected. If we don't do that HW might forward prefixes known to kernel
> incorrectly. Take an example when default route is set in switch HW and there
> is an IP address set on a management (non-switch) port.
> 
> Currently, only FIB entries related to the switch port netdev are
> offloaded using switchdev ops. This model is not extendable so the
> first patch introduces a replacement: notifier to propagate FIB entry
> additions and removals to whoever is interested.

Although I am disappointed that we need to use notifiers to support
fib offloading properly (it seems ad-hoc and hackish), I cannot come
up with a better solution to the problem. :-)

So series applied, thanks Jiri!
