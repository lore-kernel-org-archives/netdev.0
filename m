From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Mon, 06 Feb 2012 10:02:19 +0100
Message-ID: <4F2F971B.9090503@profihost.ag>
References: <20120201.162157.880976652659067010.davem@davemloft.net>		 <4F2A87B0.6070900@profihost.ag>		 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		 <20120202.143957.2251106530056768980.davem@davemloft.net>		 <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag>	 <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag> <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:38971 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135Ab2BFJCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 04:02:23 -0500
In-Reply-To: <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

> And please try a "allyesconfig" build, because it doesnt build right
> now :
> 
>   CC [M]  net/decnet/dn_neigh.o
> net/decnet/dn_route.c: In function 'dn_forward':
> net/decnet/dn_route.c:757:31: error: 'struct dst_entry' has no member
> named 'neighbour'
> make[2]: *** [net/decnet/dn_route.o] Error 1
> make[2]: *** Waiting for unfinished jobs....
> net/decnet/dn_neigh.c: In function 'dn_long_output':
> net/decnet/dn_neigh.c:230:31: error: 'struct dst_entry' has no member
> named 'neighbour'
> net/decnet/dn_neigh.c: In function 'dn_short_output':
> net/decnet/dn_neigh.c:277:31: error: 'struct dst_entry' has no member
> named 'neighbour'
> net/decnet/dn_neigh.c: In function 'dn_phase3_output':
> net/decnet/dn_neigh.c:321:31: error: 'struct dst_entry' has no member
> named 'neighbour'
> make[2]: *** [net/decnet/dn_neigh.o] Error 1
> make[1]: *** [net/decnet] Error 2
> 
> 
> So there is at least one patch missing ?

how to get an allyesconfig? Or just doing something like:
rm -f .config; /usr/bin/yes | make oldconfig

Stefan
