From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/2] net/sched: cls_flower: Support
 matching on ICMP
Date: Thu, 08 Dec 2016 11:58:10 -0500 (EST)
Message-ID: <20161208.115810.554381162900423199.davem@davemloft.net>
References: <1481114908-24189-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, tom@herbertland.com, netdev@vger.kernel.org,
        ogerlitz@mellanox.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbcLHQ6M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:58:12 -0500
In-Reply-To: <1481114908-24189-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Wed,  7 Dec 2016 13:48:26 +0100

> this series adds support for matching on ICMP type and code to
> cls_flower.

Series applied, thanks Simon.  I guess we'll see some netronome
offloading of this stuff coming soon? :-)

Simon and Or, you both added extensions to cls_flower at the same
time.  Or's changes went in first, so his UAPI numbers did not change.
Simons, your changes went in next so your numbers did change and
therefore you will have to recompile any userland components you were
using for testing.

Just FYI...
