From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] bnx2x: avoid printing unnecessary
 messages during register dump
Date: Fri, 30 Sep 2016 01:22:50 -0400 (EDT)
Message-ID: <20160930.012250.1203085597428305997.davem@davemloft.net>
References: <1475001234-25933-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
        <20160927.224349.354006077948089224.davem@davemloft.net>
        <57ED3F1B.2040602@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, Yuval.Mintz@qlogic.com,
        netdev@vger.kernel.org
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932836AbcI3FWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 01:22:55 -0400
In-Reply-To: <57ED3F1B.2040602@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Thu, 29 Sep 2016 13:19:39 -0300

> David, thanks for your comment. I confess I didn't understand your
> statement quite well. You say we shouldn't dump registers that will
> cause timeouts, that's it?

Yes, basically.

If this happened infrequently for one or two registers maybe
that would be OK, but this seems to timeout on many registers
especially if the device is up and operational during the
"ethtool -d", and that's a bit much.
