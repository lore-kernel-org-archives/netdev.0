From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: revert lib/percpu_counter API for
 fragmentation mem accounting
Date: Sun, 03 Sep 2017 11:01:20 -0700 (PDT)
Message-ID: <20170903.110120.230269539906979454.davem@davemloft.net>
References: <150425790711.22227.12264977619066874632.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkubecek@suse.cz, fw@strlen.de,
        liujian56@huawei.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753099AbdICSBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 14:01:21 -0400
In-Reply-To: <150425790711.22227.12264977619066874632.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 01 Sep 2017 11:26:03 +0200

> There is a bug in fragmentation codes use of the percpu_counter API,
> that can cause issues on systems with many CPUs, above 24 CPUs.
> 
> After much consideration and different attempts at solving the API
> usage.  The conclusion is to revert to the simple atomic_t API instead.
> 
> The ratio between batch size and threshold size make it a bad use-case
> for the lib/percpu_counter API.  As using the correct API calls will
> unfortunately cause systems with many CPUs to always execute an
> expensive sum across all CPUs. Plus the added complexity is not worth it.

Series applied, thanks Jesper.
