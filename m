From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] add stealth mode
Date: Thu, 02 Jul 2015 10:23:27 +0200
Message-ID: <5594F4FF.1000904@6wind.com>
References: <CAFnufp3wM5rb=B4N8Ad+cLcTu8sx-f9OXpqp33uCKXe=q=je3Q@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: Matteo Croce <technoboy85@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFnufp3wM5rb=B4N8Ad+cLcTu8sx-f9OXpqp33uCKXe=q=je3Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02/07/2015 00:53, Matteo Croce a =C3=A9crit :
> Add option to disable any reply not related to a listening socket,
> like RST/ACK for TCP and ICMP Dest-Unreach for UDP.
> Also disables ICMP replies to echo request and timestamp.
> The stealth mode can be enabled selectively for a single interface.
> ---
>   include/linux/inetdevice.h | 1 +
>   include/linux/ipv6.h       | 1 +
>   include/uapi/linux/ip.h    | 1 +
>   net/ipv4/devinet.c         | 1 +
>   net/ipv4/icmp.c            | 6 ++++++
>   net/ipv4/tcp_ipv4.c        | 3 ++-
>   net/ipv4/udp.c             | 4 +++-
>   net/ipv6/addrconf.c        | 7 +++++++
>   net/ipv6/icmp.c            | 3 ++-
>   net/ipv6/tcp_ipv6.c        | 2 +-
>   net/ipv6/udp.c             | 3 ++-
>   11 files changed, 27 insertions(+), 5 deletions(-)

It is recommended to add an explanation of new sysctl here:
Documentation/networking/ip-sysctl.txt
