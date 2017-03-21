From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-v5 0/4] vsock: cancel connect packets when failing to
 connect
Date: Tue, 21 Mar 2017 14:42:00 -0700 (PDT)
Message-ID: <20170321.144200.728688553537467782.davem@davemloft.net>
References: <1489541537-130429-1-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        kvm@vger.kernel.org, stefanha@redhat.com, jhansen@vmware.com
To: bergwolf@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758437AbdCUVmC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 17:42:02 -0400
In-Reply-To: <1489541537-130429-1-git-send-email-bergwolf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 15 Mar 2017 09:32:13 +0800

> Currently, if a connect call fails on a signal or timeout (e.g., guest is still
> in the process of starting up), we'll just return to caller and leave the connect
> packet queued and they are sent even though the connection is considered a failure,
> which can confuse applications with unwanted false connect attempt.
> 
> The patchset enables vsock (both host and guest) to cancel queued packets when
> a connect attempt is considered to fail.
> 
> v5 changelog:
>   - change virtio_vsock_pkt->cancel_token back to virtio_vsock_pkt->vsk
> v4 changelog:
>   - drop two unnecessary void * cast
>   - update new callback comment
> v3 changelog:
>   - define cancel_pkt callback in struct vsock_transport rather than struct virtio_transport
>   - rename virtio_vsock_pkt->vsk to virtio_vsock_pkt->cancel_token
> v2 changelog:
>   - fix queued_replies counting and resume tx/rx when necessary

Series applied, thanks.
