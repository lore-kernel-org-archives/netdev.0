From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2 net-next 0/2] net: SO_INCOMING_CPU support
Date: Fri, 14 Nov 2014 09:06:30 +0100
Message-ID: <CAHO5Pa3jQXZ3iwG4k1SW9Kf1mUCp6T3O6-niy6PVNfCAxc5J_Q@mail.gmail.com>
References: <1415714068-21028-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Ying Cai <ycai@google.com>,
	Linux API <linux-api@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:41429 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbaKNIGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 03:06:53 -0500
In-Reply-To: <1415714068-21028-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC += linux-api@]

On Tue, Nov 11, 2014 at 2:54 PM, Eric Dumazet <edumazet@google.com> wrote:
> SO_INCOMING_CPU socket option (read by getsockopt()) provides
> an alternative to RPS/RFS for high performance servers using
> multi queues NIC.
>
> TCP should use sk_mark_napi_id() for established sockets only.
>
> Eric Dumazet (2):
>   tcp: move sk_mark_napi_id() at the right place
>   net: introduce SO_INCOMING_CPU
>
>  arch/alpha/include/uapi/asm/socket.h   |  2 ++
>  arch/avr32/include/uapi/asm/socket.h   |  2 ++
>  arch/cris/include/uapi/asm/socket.h    |  2 ++
>  arch/frv/include/uapi/asm/socket.h     |  2 ++
>  arch/ia64/include/uapi/asm/socket.h    |  2 ++
>  arch/m32r/include/uapi/asm/socket.h    |  2 ++
>  arch/mips/include/uapi/asm/socket.h    |  2 ++
>  arch/mn10300/include/uapi/asm/socket.h |  2 ++
>  arch/parisc/include/uapi/asm/socket.h  |  2 ++
>  arch/powerpc/include/uapi/asm/socket.h |  2 ++
>  arch/s390/include/uapi/asm/socket.h    |  2 ++
>  arch/sparc/include/uapi/asm/socket.h   |  2 ++
>  arch/xtensa/include/uapi/asm/socket.h  |  2 ++
>  include/net/sock.h                     | 12 ++++++++++++
>  include/uapi/asm-generic/socket.h      |  2 ++
>  net/core/sock.c                        |  5 +++++
>  net/ipv4/tcp_ipv4.c                    |  4 +++-
>  net/ipv4/udp.c                         |  1 +
>  net/ipv6/tcp_ipv6.c                    |  4 +++-
>  net/ipv6/udp.c                         |  1 +
>  net/sctp/ulpqueue.c                    |  5 +++--
>  21 files changed, 56 insertions(+), 4 deletions(-)
>
> --
> 2.1.0.rc2.206.gedb03e5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/
