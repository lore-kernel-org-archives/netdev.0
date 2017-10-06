From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/5] VSOCK: add sock_diag interface
Date: Thu, 05 Oct 2017 20:40:30 -0700 (PDT)
Message-ID: <20171005.204030.522329909569141573.davem@davemloft.net>
References: <20171005204654.2737-1-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56848 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdJFDko (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 23:40:44 -0400
In-Reply-To: <20171005204654.2737-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu,  5 Oct 2017 16:46:49 -0400

> v3:
>  * Rebased onto net-next/master and resolved Hyper-V transport conflict
> 
> v2:
>  * Moved tests to tools/testing/vsock/.  I was unable to put them in selftests/
>    because they require manual setup of a VMware/KVM guest.
>  * Moved to __vsock_in_bound/connected_table() to af_vsock.h
>  * Fixed local variable ordering in Patch 4
> 
> There is currently no way for userspace to query open AF_VSOCK sockets.  This
> means ss(8), netstat(8), and other utilities cannot display AF_VSOCK sockets.
> 
> This patch series adds the netlink sock_diag interface for AF_VSOCK.  Userspace
> programs sent a DUMP request including an sk_state bitmap to filter sockets
> based on their state (connected, listening, etc).  The vsock_diag.ko module
> replies with information about matching sockets.  This userspace ABI is defined
> in <linux/vm_sockets_diag.h>.
> 
> The final patch adds a test suite that exercises the basic cases.
> 
> Jorgen and Dexuan: I have only tested the virtio transport but this should also
> work for VMCI and Hyper-V.  Please give it a shot if you have time.

Series applied, thanks.
