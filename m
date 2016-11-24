From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] VSOCK: add loopback to virtio_transport
Date: Thu, 24 Nov 2016 11:54:00 -0500 (EST)
Message-ID: <20161124.115400.234424564137643675.davem@davemloft.net>
References: <1479736591-25235-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cavery@redhat.com,
        imbrenda@linux.vnet.ibm.com, jhansen@vmware.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756864AbcKXQyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 11:54:04 -0500
In-Reply-To: <1479736591-25235-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Mon, 21 Nov 2016 13:56:31 +0000

> The VMware VMCI transport supports loopback inside virtual machines.
> This patch implements loopback for virtio-vsock.
> 
> Flow control is handled by the virtio-vsock protocol as usual.  The
> sending process stops transmitting on a connection when the peer's
> receive buffer space is exhausted.
> 
> Cathy Avery <cavery@redhat.com> noticed this difference between VMCI and
> virtio-vsock when a test case using loopback failed.  Although loopback
> isn't the main point of AF_VSOCK, it is useful for testing and
> virtio-vsock must match VMCI semantics so that userspace programs run
> regardless of the underlying transport.
> 
> My understanding is that loopback is not supported on the host side with
> VMCI.  Follow that by implementing it only in the guest driver, not the
> vhost host driver.
> 
> Cc: Jorgen Hansen <jhansen@vmware.com>
> Reported-by: Cathy Avery <cavery@redhat.com>
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> v2:
>  * Fixed checkpatch.pl warnings [DaveM]

Applied to net-next, thanks.
