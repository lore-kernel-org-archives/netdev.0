From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] htb: report overhead attribute
Date: Fri, 7 Jun 2013 08:56:11 -0700
Message-ID: <20130607085611.5582dec1@nehalam.linuxnetplumber.net>
References: <20130529151330.22c5c89e@redhat.com>
	<1370207755.24311.81.camel@edumazet-glaptop>
	<1370208781.24311.89.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:39930 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab3FGP4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 11:56:16 -0400
Received: by mail-pb0-f53.google.com with SMTP id xb12so4759985pbc.40
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 08:56:16 -0700 (PDT)
In-Reply-To: <1370208781.24311.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Jun 2013 14:33:01 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> "tc class show dev ..." omits the overhead attribute for HTB.
> 
> After patch I have :
> 
> tc class add dev $DEV parent 1: classid 1:1 est 1sec 4sec htb \
>     rate 12Mbit mtu 1500 quantum 1514 overhead 20
> 
> tc class show dev $DEV
> class htb 1:1 root prio 0 rate 12000Kbit overhead 20 ceil 12000Kbit
> burst 1500b cburst 1500b
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
And after that fixed indentation of q_htb.c
