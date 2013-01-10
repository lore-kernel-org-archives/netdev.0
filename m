From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: niu interface automatically goes up then down
Date: Thu, 10 Jan 2013 11:24:00 +1100
Message-ID: <CAGRGNgWqweBphbr+rpTZ2Fe=yLG_xNSvS4sf8XteoCiAx8b81A@mail.gmail.com>
References: <alpine.LNX.2.01.1301092342290.21351@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	sparclinux@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:45008 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab3AJAYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 19:24:23 -0500
In-Reply-To: <alpine.LNX.2.01.1301092342290.21351@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jan,

I'm not familiar with the hardware or drivers, so I won't be able to
help you that much either, but I can ask a couple of pointed
questions. =)

On Thu, Jan 10, 2013 at 9:58 AM, Jan Engelhardt <jengelh@inai.de> wrote:
> Hi,
>
> I am observing that a machine with a niu card/driver automatically
> enables itself and then goes dormant again.
>
> [ 4410.930078] niu 0000:10:00.0 eth4: Link is up at 100Mbit/sec, full duplex
> [ 4410.930137] br0: port 4(eth4) entered forwarding state
> [ 4410.930156] br0: port 4(eth4) entered forwarding state
> [ 4420.957745] niu 0000:10:00.0 eth4: Link is down
>
> The interface itself is marked UP, and is part of a bridge,
> if that matters. The kernel version is 3.7.1 on sparc64.
>
> 6: eth4: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500
> qdisc mq master br0 state DOWN qlen 1000
>     link/ether 00:21:28:71:32:5a brd ff:ff:ff:ff:ff:ff
>     inet6 fe80::221:28ff:fe71:325a/64 scope link
>        valid_lft forever preferred_lft forever

That is rather odd. Is this particular interface connected to anything
that could be causing this?

> At the same time, eth5, to which a cable+machine _is_ connected,
> randomly goes out. At first I thought it might be the connected peer,
> but seeing that eth4 randomly does a up-down cycle leads me to assume
> that niu is doing a cycle here rather than the peer.
>
> [ 3839.724721] niu 0000:10:00.1 eth5: Link is down
> [ 3839.725077] br0: port 5(eth5) entered disabled state
> [ 3840.725016] niu 0000:10:00.1 eth5: Link is up at 100Mbit/sec, half duplex
> [ 3840.725195] br0: port 5(eth5) entered forwarding state
> [ 3840.725327] br0: port 5(eth5) entered forwarding state
> [ 3855.762171] br0: port 5(eth5) entered forwarding state

Again, could it be the device at the end of the link?

Out of curiosity, why do you have these two ports bridged together and
what is the purpose of this configuration?

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
