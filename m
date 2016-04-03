From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: Re: [PATCH v2 net-next 0/8] add TX timestamping via cmsg
Date: Sat, 2 Apr 2016 21:36:16 -0400
Message-ID: <CADAM+B06fkY-OT8-Po06Tu6CdVhh7FAvx5W5-_2NXTex_MmV8g@mail.gmail.com>
References: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
	<20160402.211942.598210499165268433.davem@davemloft.net>
	<20160402.212729.2129485115379390591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:36738 "EHLO
	mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbcDCBgR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 21:36:17 -0400
Received: by mail-vk0-f68.google.com with SMTP id x190so2410176vka.3
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 18:36:17 -0700 (PDT)
In-Reply-To: <20160402.212729.2129485115379390591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 2, 2016 at 9:27 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 02 Apr 2016 21:19:42 -0400 (EDT)
>
>> Series applied, thanks.
>
> I had to revert, this breaks the build:
>
> net/l2tp/l2tp_ip6.c: In function =E2=80=98l2tp_ip6_sendmsg=E2=80=99:
> net/l2tp/l2tp_ip6.c:565:9: error: too few arguments to function =E2=80=
=98ip6_datagram_send_ctl=E2=80=99
>    err =3D ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
>          ^
> In file included from net/l2tp/l2tp_ip6.c:33:0:
> include/net/transp_v6.h:43:5: note: declared here
>  int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct m=
sghdr *msg,
>      ^
> net/l2tp/l2tp_ip6.c:625:8: error: too few arguments to function =E2=80=
=98ip6_append_data=E2=80=99
>   err =3D ip6_append_data(sk, ip_generic_getfrag, msg,
>         ^
> In file included from include/net/inetpeer.h:15:0,
>                  from include/net/route.h:28,
>                  from include/net/ip.h:31,
>                  from net/l2tp/l2tp_ip6.c:23:
> include/net/ipv6.h:865:5: note: declared here
>  int ip6_append_data(struct sock *sk,
>      ^

I'm really sorry about this. CONFIG_L2TP was no enabled in my config.
I'll fix the patch, and will mail v3.

Thanks,
Soheil
