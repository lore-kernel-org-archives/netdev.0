From: Marcin Kaminski <maxiu@man.poznan.pl>
Subject: Re: socket(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6)
Date: Wed, 12 Mar 2003 13:51:53 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0303121348470.23508-100000@rose.man.poznan.pl>
References: <20030312.213903.04850857.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030312.213903.04850857.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Mar 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明
wrote:

> > What should I do in order to get full packet?
>
> There're no portable way to send/receive whole packet including
> IPv6 header (and possible extension header(s)).

OK.
Is there simplier method of obtaining source and destaination address of
icmp packet (the only informations I need from ipv6 header) than setting
IPV6_PKTINFO and receiving them with recvmsg?
