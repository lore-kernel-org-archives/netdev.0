From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/2] netpoll:  Remove dead netpoll_rx code
Date: Tue, 11 Mar 2014 05:29:21 -0700
Message-ID: <1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871ty9qvaf.fsf_-_@xmission.com>
	 <87vbvlpgnk.fsf_-_@xmission.com>
	 <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140311.004217.1616529960369263682.davem@davemloft.net>
	 <1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cxf7mp.fsf_-_@xmission.com> <8738ipf7kn.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:57050 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbaCKM3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 08:29:24 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so8506424pdi.33
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 05:29:23 -0700 (PDT)
In-Reply-To: <8738ipf7kn.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 01:44 -0700, Eric W. Biederman wrote:
> The netpoll_rx code only becomes active if the netpoll rx_skb_hook is
> implemented.  There is not a single implementation of the netpoll
> rx_skb_hook in the kernel.
> 
> There are problems with the netpoll packet receive code. Most
> speifically every packet that makes it to netpoll_neigh_reply is
> leaked.
> 
> Given that the netpoll packet receive code is buggy and has not been used
> for a decade let's just remove it.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/Kconfig       |    5 -
>  include/linux/netdevice.h |   17 --
>  include/linux/netpoll.h   |   59 ------
>  net/core/dev.c            |   11 +-
>  net/core/netpoll.c        |  471 ---------------------------------------------
>  5 files changed, 1 insertions(+), 562 deletions(-)

I cannot agree more, thanks Eric.

Acked-by: Eric Dumazet <edumazet@google.com>
