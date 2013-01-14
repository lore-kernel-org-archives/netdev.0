From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Mon, 14 Jan 2013 15:35:40 -0800
Message-ID: <CAGK4HS8tHrNUBfd8jmRtWNwFwBARsj7jyxbhD8C7OhhHnpqfQQ@mail.gmail.com>
References: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com>
	<20130114.152906.967716859913059764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:32893 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805Ab3ANXfl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 18:35:41 -0500
Received: by mail-qc0-f176.google.com with SMTP id n41so2826946qco.21
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 15:35:40 -0800 (PST)
In-Reply-To: <20130114.152906.967716859913059764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 January 2013 12:29, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 14 Jan 2013 12:00:16 -0800 (PST)
>
>> Rebasing the soreuseport patches to 3.8.  No material changes since
>> first posted.

Tom,
I am not sure if this series was just RFC or you already are aware of
this but  I got the following errors when compiling with
CONFIG_NETFILTER_TPROXY=3Dm

This is because the definitions of inet_lookup_listener  and
inet6_lookup_listener have changed with your patch.

In file included from net/netfilter/nf_tproxy_core.c:19:
include/net/netfilter/nf_tproxy_core.h: In function =91nf_tproxy_get_so=
ck_v4=92:
include/net/netfilter/nf_tproxy_core.h:86: error: too few arguments to
function =91inet_lookup_listener=92
include/net/netfilter/nf_tproxy_core.h: In function =91nf_tproxy_get_so=
ck_v6=92:
include/net/netfilter/nf_tproxy_core.h:155: warning: passing argument
5 of =91inet6_lookup_listener=92 makes pointer from integer without a c=
ast
include/net/inet6_hashtables.h:72: note: expected =91const struct
in6_addr *=92 but argument is of type =91int=92
include/net/netfilter/nf_tproxy_core.h:155: error: too few arguments
to function =91inet6_lookup_listener=92
make[1]: *** [net/netfilter/nf_tproxy_core.o] Error 1
make[1]: *** Waiting for unfinished jobs....


Thanks,
Vijay
