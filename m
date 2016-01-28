From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH next] ipvlan: inherit MTU from master device
Date: Thu, 28 Jan 2016 05:13:02 -0800
Message-ID: <CANn89iJXmdaq=Rc20QriH+QL8Nug_g4zRUO8BFw04pdAWQ6BEA@mail.gmail.com>
References: <1453966408-16343-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>,
	Tim Hockin <thockin@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tim Hockins <thockins@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35286 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548AbcA1NNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 08:13:04 -0500
Received: by mail-wm0-f49.google.com with SMTP id r129so24167942wmr.0
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 05:13:02 -0800 (PST)
In-Reply-To: <1453966408-16343-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 11:33 PM, Mahesh Bandewar <mahesh@bandewar.net> wrote:
> From: Mahesh Bandewar <maheshb@google.com>
>
> When we create IPvlan slave; we use ether_setup() and that
> sets up default MTU to 1500 while the master device may have
> lower / different MTU. Any subsequent changes to the masters'
> MTU are reflected into the slaves' MTU setting. However if those
> don't happen (most likely scenario), the slaves' MTU stays at
> 1500 which could be bad.
>
> This change adds code to inherit MTU from the master device
> instead of using the default value during the link initialization
> phase.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tim Hockins <thockins@google.com>
>

Acked-by: Eric Dumazet <edumazet@google.com>

Two points Mahesh :

1) ipvlan_adjust_mtu() could be static, it is only used from
drivers/net/ipvlan/ipvlan_main.c

2) mtu_adj does not seem to be used ?
