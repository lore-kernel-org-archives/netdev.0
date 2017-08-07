From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] net: l3mdev: Support for sockets bound to
 enslaved device
Date: Mon, 7 Aug 2017 08:35:30 -0600
Message-ID: <16d93042-4be1-dcc7-9a8f-a0a1440d5564@gmail.com>
References: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
 <20170806.213938.1049251959507174455.davem@davemloft.net>
 <20170806.235145.398118943167397128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35786 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdHGOfh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 10:35:37 -0400
Received: by mail-pg0-f65.google.com with SMTP id l64so547253pge.2
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 07:35:36 -0700 (PDT)
In-Reply-To: <20170806.235145.398118943167397128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/7/17 12:51 AM, David Miller wrote:
> David, I had to revert.  You didn't convert dccp which breaks
> the build.
> 
> net/dccp/ipv4.c: In function ¡dccp_v4_err¢:
> net/dccp/ipv4.c:256:7: error: too few arguments to function ¡__inet_lookup_established¢
>   sk = __inet_lookup_established(net, &dccp_hashinfo,
>        ^~~~~~~~~~~~~~~~~~~~~~~~~
> In file included from net/dccp/ipv4.c:22:0:
> ./include/net/inet_hashtables.h:289:14: note: declared here
>  struct sock *__inet_lookup_established(struct net *net,
>               ^~~~~~~~~~~~~~~~~~~~~~~~~

That's embarrassing. Will fix
