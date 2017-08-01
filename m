From: David Miller <davem@davemloft.net>
Subject: net-next virtio_net merge...
Date: Tue, 01 Aug 2017 15:12:20 -0700 (PDT)
Message-ID: <20170801.151220.241719275238287015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752267AbdHAWMV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 18:12:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just merged net into net-next and one of the conflicts had to do with
the truesize bug fix in 'net' conflicting with the changes in 'net-next'
which encode the headroom into the contexts for mergeable buffers.

I did my best to resolve this, but if you two would take a closer
look and test out the result I would really appreciate it!

Thanks.
