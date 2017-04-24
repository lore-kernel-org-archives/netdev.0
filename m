From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/3] VSOCK: vsockmon virtual device to monitor
 AF_VSOCK sockets.
Date: Mon, 24 Apr 2017 12:36:33 -0400 (EDT)
Message-ID: <20170424.123633.1996395785851142975.davem@davemloft.net>
References: <20170421091046.5599-1-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zyjzyj2000@gmail.com, mst@redhat.com,
        ggarcia@abra.uab.cat, jhansen@vmware.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758876AbdDXQgr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:36:47 -0400
In-Reply-To: <20170421091046.5599-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Fri, 21 Apr 2017 10:10:43 +0100

> This is a continuation of Gerard Garcia's work on the vsockmon packet capture
> interface for AF_VSOCK.  Packet capture is an essential feature for network
> communication.  Gerard began addressing this feature gap in his Google Summer
> of Code 2016 project.  I have cleaned up, rebased, and retested the v2 series
> he posted previously.
> 
> The design follows the nlmon packet capture interface closely.  This is because
> vsock has the same problem as netlink: there is no netdev on which packets can
> be captured.  The nlmon driver is a synthetic netdev purely for the purpose of
> enabling packet capture.  We follow the same approach here with vsockmon.
> 
> See include/uapi/linux/vsockmon.h in this series for details on the packet
> layout.

Series applied, thanks.
