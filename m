From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
	online CPUs default
Date: Tue, 23 Mar 2010 19:58:16 +0800
Message-ID: <412e6f7f1003230458o459b9e45i7327c5330c43e152@mail.gmail.com>
References: <4BA85EA2.1090304@gmail.com> <1269329250.3043.19.camel@edumazet-laptop>
	<412e6f7f1003230303l69fc142ey1581fff4c3e749be@mail.gmail.com>
	<1269344306.2983.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:43104 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab0CWL6h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 07:58:37 -0400
Received: by iwn6 with SMTP id 6so1680993iwn.4
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 04:58:36 -0700 (PDT)
In-Reply-To: <1269344306.2983.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 23, 2010 at 7:38 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 23 mars 2010 =C3=A0 18:03 +0800, Changli Gao a =C3=A9crit :
>
>
> I know _many_ applications that perform better when all network IRQS =
are
> directed to one CPU only. Single threaded UDP server for example, wit=
h
> fast answer, or routers, or ...

Yea, single threaded applicatons can't get much from RPS, but
multi-threaded applications such as apache do. And more and more
applications are programmed with the assumption there are more than
one CPUs/Cores.

>
> Many sysadmins tuned their machine to meet this requirement. Installi=
ng
> 2.6.35, if RPS enabled by default will make them unhappy, especially =
if
> CONFIG_SYSFS is not set, since they wont be able to change RPS settin=
gs.
>
> If RPS was good for all workloads, activating it would make sense, bu=
t
> this is not the case.
>

The sysadmins you mentioned above are Linux experters, and they know
how to tunning the system to get the best performance, but the default
configuration should be for the ordinary users, who don't know Linux
much.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
