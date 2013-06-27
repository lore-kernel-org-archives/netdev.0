From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC Patch net-next 0/5] net: introduce generic type and helpers
 for IP address
Date: Thu, 27 Jun 2013 09:03:06 +0200
Message-ID: <51CBE3AA.5070008@redhat.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab3F0HDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 03:03:09 -0400
In-Reply-To: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amerigo,

On 06/27/2013 08:43 AM, Cong Wang wrote:
> As IPv6 becomes popular, more and more subsystems begin to support IPv6,
> therefore we need a generic IP address type, in case of duplicates.
> Also we will also need some helpers to compare, print, check the generic
> IP address.
>
> This patchset introduce a new type union inet_addr as a union of IPv4
> and IPv6 address, and some helper functions that will be used by existing
> code and in the future VXLAN module.
>
> This patchset only does compile test, since it is still RFC.

This patch already does that which I've sent yesterday before yours ...

   [PATCH net-next 1/2] lib: vsprintf: add IPv4/v6 generic %pig/%pIg format specifier

... and resend with the set today in the morning as v2 with provided
feedback applied. Can't you base yours on top of that?

Thanks !

> Cong Wang (5):
>    net: introduce generic union inet_addr
>    net: introduce generic inet_pton()
>    inetpeer: use generic union inet_addr
>    sunrpc: use generic union inet_addr
>    nfs,cifs: abstract generic inet_addr_equal_strict()
>
>   Documentation/printk-formats.txt |    9 ++
>   drivers/net/netconsole.c         |   22 +++---
>   fs/cifs/connect.c                |   38 ++-------
>   fs/dlm/lowcomms.c                |   24 +-----
>   fs/nfs/client.c                  |   94 +--------------------
>   fs/nfs/nfs4filelayoutdev.c       |   37 +--------
>   fs/nfs/super.c                   |   31 +-------
>   include/linux/netpoll.h          |    9 +--
>   include/linux/sunrpc/addr.h      |  119 ++-------------------------
>   include/net/inet_addr.h          |  164 ++++++++++++++++++++++++++++++++++++++
>   include/net/inetpeer.h           |   29 ++-----
>   lib/vsprintf.c                   |   18 ++++-
>   net/core/netpoll.c               |   74 ++++++-----------
>   net/ipv4/inetpeer.c              |   35 +++++---
>   net/ipv4/tcp_metrics.c           |   92 +++++++++-------------
>   15 files changed, 327 insertions(+), 468 deletions(-)
>   create mode 100644 include/net/inet_addr.h
>
