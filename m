From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] ip: mroute: Print offload indication
Date: Wed, 11 Oct 2017 10:55:02 -0700
Message-ID: <20171011105502.76f09b5e@xeon-e3>
References: <20171008144304.48850-1-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mlxsw@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:47016 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752190AbdJKRzJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 13:55:09 -0400
Received: by mail-pg0-f52.google.com with SMTP id k7so1397257pga.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 10:55:09 -0700 (PDT)
In-Reply-To: <20171008144304.48850-1-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  8 Oct 2017 17:43:04 +0300
Yotam Gigi <yotamg@mellanox.com> wrote:

> Since kernel net-next commit c7c0bbeae950 ("net: ipmr: Add MFC offload
> indication") the kernel indicates on an MFC entry whether it was offloaded
> using the RTNH_F_OFFLOAD flag. Update the "ip mroute show" command to
> indicate when a route is offloaded, similarly to the "ip route show"
> command.
> 
> Example output:
> $ ip mroute
> (0.0.0.0, 239.255.0.1)      Iif: sw1p7  Oifs: t_br0 State: resolved offload
> (192.168.1.1, 239.255.0.1)  Iif: sw1p7  Oifs: sw1p4 State: resolved offload
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Looks good, applied.
Thanks.
