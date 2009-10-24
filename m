From: Dunc <dunc@lemonia.org>
Subject: Re: Request: how do packet routing based on input gateway
Date: Sat, 24 Oct 2009 15:19:45 +0100
Message-ID: <4AE30D01.7030700@lemonia.org>
References: <73dbe2850910240622s2453c252p17d928f8a94ffe33@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Luca Dionisi <luca.dionisi@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <73dbe2850910240622s2453c252p17d928f8a94ffe33@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If both of your last hops are on the same subnet you can't use incoming
interface, so the only thing I can think of is to match the MAC address
of the ethernet frame. If the last hop wasn't the source of the packet I
don't think there's anything else to uniquely identify it.

Cheers,

Dunc


Luca Dionisi wrote:
> Hi all
> 
> I must instruct my server to route packets based on destination prefix
> and on the gateway from which the packet arrived.
> E.g.
>  I am 192.168.0.1
>  a packet for 192.168.1.0/24 which arrived from gateway 192.168.0.2
> must go through 192.168.1.1 dev eth0
>  a packet for 192.168.1.0/24 which arrived from gateway 192.168.0.3
> must go through 192.168.1.2 dev eth1
>  a packet for 192.168.1.0/24 which arrived from any other gateway must
> go through 192.168.1.3 dev eth2
> 
> The gateway I mean is just the last hop traversed, before me. It's not
> necessarily the source of the packet.
> 
> How am I supposed to do that?
> 
> Regards.
> Luca Dionisi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

