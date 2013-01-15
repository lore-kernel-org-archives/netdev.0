From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same port
Date: Mon, 14 Jan 2013 17:33:29 -0800
Message-ID: <CA+mtBx-tz-OMN224PEgWkQPQTrQ6AUox7i2+Y3hheW-bcjPo1w@mail.gmail.com>
References: <alpine.DEB.2.00.1301141138440.959@pokey.mtv.corp.google.com>
	<20130114.152906.967716859913059764.davem@davemloft.net>
	<CAGK4HS8tHrNUBfd8jmRtWNwFwBARsj7jyxbhD8C7OhhHnpqfQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:45182 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757677Ab3AOBlo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 20:41:44 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so6318989ieb.33
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 17:41:44 -0800 (PST)
In-Reply-To: <CAGK4HS8tHrNUBfd8jmRtWNwFwBARsj7jyxbhD8C7OhhHnpqfQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 14, 2013 at 3:35 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> On 14 January 2013 12:29, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Mon, 14 Jan 2013 12:00:16 -0800 (PST)
>>
>>> Rebasing the soreuseport patches to 3.8.  No material changes since
>>> first posted.
>
> Tom,
> I am not sure if this series was just RFC or you already are aware of
> this but  I got the following errors when compiling with
> CONFIG_NETFILTER_TPROXY=3Dm
>
Thanks,
I'll fix that.

Tom

> This is because the definitions of inet_lookup_listener  and
> inet6_lookup_listener have changed with your patch.
>
> In file included from net/netfilter/nf_tproxy_core.c:19:
> include/net/netfilter/nf_tproxy_core.h: In function =91nf_tproxy_get_=
sock_v4=92:
> include/net/netfilter/nf_tproxy_core.h:86: error: too few arguments t=
o
> function =91inet_lookup_listener=92
> include/net/netfilter/nf_tproxy_core.h: In function =91nf_tproxy_get_=
sock_v6=92:
> include/net/netfilter/nf_tproxy_core.h:155: warning: passing argument
> 5 of =91inet6_lookup_listener=92 makes pointer from integer without a=
 cast
> include/net/inet6_hashtables.h:72: note: expected =91const struct
> in6_addr *=92 but argument is of type =91int=92
> include/net/netfilter/nf_tproxy_core.h:155: error: too few arguments
> to function =91inet6_lookup_listener=92
> make[1]: *** [net/netfilter/nf_tproxy_core.o] Error 1
> make[1]: *** Waiting for unfinished jobs....
>
>
> Thanks,
> Vijay
