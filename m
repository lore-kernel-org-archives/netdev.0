From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 0/3] ss: add AF_VSOCK support
Date: Wed, 11 Oct 2017 10:52:00 -0700
Message-ID: <20171011105200.7ed68d3b@xeon-e3>
References: <20171006154841.10495-1-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:44761 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdJKRwI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:52:08 -0400
Received: by mail-pf0-f180.google.com with SMTP id x7so1494800pfa.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:52:08 -0700 (PDT)
In-Reply-To: <20171006154841.10495-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  6 Oct 2017 11:48:38 -0400
Stefan Hajnoczi <stefanha@redhat.com> wrote:

> v2:
>  * Use uint64_t instead of __u64 for filter->families
>  * Added reference to net-next commit that merged vsock_diag.ko
> 
> This patch series adds AF_VSOCK support to ss(8).  AF_VSOCK is a host<->guest
> communications channel supported by VMware, KVM (virtio-vsock), and Hyper-V.
> 
> To dump AF_VSOCK sockets:
> 
>   $ ss --vsock
> 
> The vsock_diag.ko module has now been merged in the Linux net-next tree.  I
> have verified that the <linux/vm_sockets_diag.h> header copy in this patch
> series is in sync with Linux net-next.  See commit
> 5820299a271fd3dc9b1733e1e10cd7b983edd028 ("Merge branch 'VSOCK-sock_diag'").
> 
> Stefan Hajnoczi (3):
>   ss: allow AF_FAMILY constants >32
>   include: add <linux/vm_sockets_diag.h>
>   ss: add AF_VSOCK support
> 
>  include/linux/vm_sockets_diag.h |  33 ++++++
>  misc/ss.c                       | 238 +++++++++++++++++++++++++++++++++++-----
>  man/man8/ss.8                   |   8 +-
>  3 files changed, 249 insertions(+), 30 deletions(-)
>  create mode 100644 include/linux/vm_sockets_diag.h
> 

Thanks Stefan.
Applied to iproute2 net-next branch.
Headers got rearranged recently.
