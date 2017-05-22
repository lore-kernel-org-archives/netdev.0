From: Mikulas Patocka <mpatocka@redhat.com>
Subject: network performance degradation in virtio_net in 4.12-rc
Date: Mon, 22 May 2017 10:25:19 -0400 (EDT)
Message-ID: <alpine.LRH.2.02.1705221003450.20076@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933994AbdEVOZX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 10:25:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I see severe network performance degradation with the kernels 4.12-rc1 and 
4.12-rc2 in the network virtio driver. Download rate drops down to about 
100kB/s.

I bisected it and it is caused by patch 
d85b758f72b05a774045545f24d70980e3e9aac4 ("virtio_net: fix support for 
small rings"). When I revert this patch, the problem goes away.

The host is Debian Jessie with kernel 4.4.62, the guest is Debian Sid with 
kernel 4.12-rc.

Mikulas
