From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: diag: support SOCK_DESTROY for UDP
 sockets
Date: Mon, 22 Aug 2016 19:15:41 -0700
Message-ID: <1471918541.14381.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471914221-24213-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33802 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753286AbcHWCPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 22:15:44 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so9019196pac.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 19:15:43 -0700 (PDT)
In-Reply-To: <1471914221-24213-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-08-22 at 18:03 -0700, David Ahern wrote:
> This implements SOCK_DESTROY for UDP sockets similar to what was done
> for TCP with commit c1e64e298b8ca ("net: diag: Support destroying TCP
> sockets.") A process with a UDP socket targeted for destroy is awakened
> and recvmsg fails with ECONNABORTED.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - changed socket lookup to __udp{4,6}_lib_lookup
> 
>  include/net/udp.h   |  1 +
>  net/ipv4/udp.c      | 17 +++++++++++++++++
>  net/ipv4/udp_diag.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/udp.c      |  1 +
>  4 files changed, 74 insertions(+)

Hi David

It seems you forgot the sock_diag_check_cookie() call, but other than
that this patch looks fine.

Thanks.
