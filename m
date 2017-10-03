From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/3] include: add <linux/vm_sockets_diag.h>
Date: Tue, 3 Oct 2017 11:24:55 -0700
Message-ID: <20171003112455.5ebac674@xeon-e3>
References: <20171003175744.24987-1-stefanha@redhat.com>
        <20171003175744.24987-3-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:43042 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdJCSZD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 14:25:03 -0400
Received: by mail-pf0-f180.google.com with SMTP id d2so1802967pfh.0
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 11:25:03 -0700 (PDT)
In-Reply-To: <20171003175744.24987-3-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Oct 2017 13:57:43 -0400
Stefan Hajnoczi <stefanha@redhat.com> wrote:

> This new Linux header file defines the sock_diag interface used by
> AF_VSOCK.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  include/linux/vm_sockets_diag.h | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
>  create mode 100644 include/linux/vm_sockets_diag.h
> 

All header files in linux must be headers that come from 'make install_headers'
in kernel. I don't see vm_sockets_diag.h even in net-next.
