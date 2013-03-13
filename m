From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 1/6] GRE: Use RTNL for atomic protocol registration.
Date: Thu, 14 Mar 2013 00:22:30 +0100
Message-ID: <CAHXqBFJzomhYjQvF+3+aNRjpZzByu-U=s5rGVnxwyL+6vemPTw@mail.gmail.com>
References: <1363214907-3257-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34094 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755623Ab3CMXWw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 19:22:52 -0400
Received: by mail-ie0-f174.google.com with SMTP id k10so2219165iea.5
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 16:22:52 -0700 (PDT)
In-Reply-To: <1363214907-3257-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/13 Pravin B Shelar <pshelar@nicira.com>:
> Currently gre demultiplexer uses its own spin-lock. We should
> rather RTNL lock.
[...]
> +       rtnl_lock();
>         err =3D gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
> +       rtnl_unlock();

Why not keep lock/unlock inside gre_add/del_protocol()?

Best Regards,
Micha=C5=82 Miros=C5=82aw
