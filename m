From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] qdisc and tx_queue_len cleanups for
 IFF_NO_QUEUE devices
Date: Mon, 07 Nov 2016 13:13:44 -0500 (EST)
Message-ID: <20161107.131344.1991435301554344262.davem@davemloft.net>
References: <20161103135534.28737.37657.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, robert@herjulf.se,
        jhs@mojatatu.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932526AbcKGSNq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 13:13:46 -0500
In-Reply-To: <20161103135534.28737.37657.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 03 Nov 2016 14:55:56 +0100

> This patchset is a cleanup for IFF_NO_QUEUE devices.  It will
> hopefully help userspace get a more consistent behavior when attaching
> qdisc to such virtual devices.

I'm still thinking about this.

My reservation about this is basically since the one known offender in
userspace acknowledged that what it was doing wrong, and fixed it
quickly already, I see no reason to explicitly accomodate this.
