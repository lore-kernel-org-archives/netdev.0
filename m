From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: udp4: move GSO functions to udp_offload
Date: Mon, 24 Jun 2013 01:41:35 -0700
Message-ID: <1372063295.3301.52.camel@edumazet-glaptop>
References: <1370688963-32635-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Pravin B Shelar <pshelar@nicira.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:45952 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848Ab3FXIlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 04:41:40 -0400
Received: by mail-bk0-f54.google.com with SMTP id it16so4079974bkc.13
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 01:41:38 -0700 (PDT)
In-Reply-To: <1370688963-32635-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-08 at 12:56 +0200, Daniel Borkmann wrote:
> Similarly to TCP offloading and UDPv6 offloading, move all related
> UDPv4 functions to udp_offload.c to make things more explicit. Also,
> by this, we can make those functions static.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/udp.h      |   7 ++--
>  net/ipv4/Makefile      |   2 +-
>  net/ipv4/af_inet.c     |   9 +----
>  net/ipv4/udp.c         |  75 +------------------------------------
>  net/ipv4/udp_offload.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 108 insertions(+), 85 deletions(-)
>  create mode 100644 net/ipv4/udp_offload.c

Daniel, the same could be done for GRE, ie moving GSO stuff into
net/ipv4/gre_offload.c

Tell me if you do not have the time to do this, I will handle it.

Thanks
