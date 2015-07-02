From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] add stealth mode
Date: Thu, 02 Jul 2015 10:49:08 +0200
Message-ID: <5594FB04.8070507@6wind.com>
References: <CAFnufp3wM5rb=B4N8Ad+cLcTu8sx-f9OXpqp33uCKXe=q=je3Q@mail.gmail.com> <5594F4FF.1000904@6wind.com> <CAFnufp0sR-3PqYT0=reML2pn_-rvOvD3EDkGivrUeguNRwQYUA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matteo Croce <technoboy85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35183 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779AbbGBItR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 04:49:17 -0400
Received: by wiga1 with SMTP id a1so146427306wig.0
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 01:49:15 -0700 (PDT)
In-Reply-To: <CAFnufp0sR-3PqYT0=reML2pn_-rvOvD3EDkGivrUeguNRwQYUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/07/2015 10:38, Matteo Croce a =C3=A9crit :
> Add option to disable any reply not related to a listening socket,
> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
> Also disables ICMP replies to echo request and timestamp.
> The stealth mode can be enabled selectively for a single interface.
>
> Signed-off-by: Matteo Croce <matteo@openwrt.org>
> ---
>   Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>   include/linux/inetdevice.h             |  1 +
>   include/linux/ipv6.h                   |  1 +
>   include/uapi/linux/ip.h                |  1 +
>   net/ipv4/devinet.c                     |  1 +
>   net/ipv4/icmp.c                        |  6 ++++++
>   net/ipv4/tcp_ipv4.c                    |  3 ++-
>   net/ipv4/udp.c                         |  4 +++-
>   net/ipv6/addrconf.c                    |  7 +++++++
>   net/ipv6/icmp.c                        |  3 ++-
>   net/ipv6/tcp_ipv6.c                    |  2 +-
>   net/ipv6/udp.c                         |  3 ++-
>   12 files changed, 39 insertions(+), 5 deletions(-)
Please, read=20
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Doc=
umentation/SubmittingPatches

The subject of your email should contain v2 and you should describe the=
 change
from v1 after the '---'.
Also, right now, net-next is closed, so new features are not accepted.


Regards,
Nicolas
