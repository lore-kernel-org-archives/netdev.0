From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down interface
Date: Thu, 1 Jul 2010 13:48:06 +0200
Message-ID: <OF62725CEB.B49F22DB-ONC1257753.003F7EAD-C1257753.0040D41F@transmode.se>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>	<20100611084854.0680c014@nehalam>
	<OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se> <871vbn1m52.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:40245 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680Ab0GALvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 07:51:20 -0400
In-Reply-To: <871vbn1m52.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> wrote on 2010/07/01 13:23:21:
>
> Joakim Tjernlund <joakim.tjernlund@transmode.se> writes:
>
> > Stephen Hemminger <shemminger@vyatta.com> wrote on 2010/06/11 17:48:54:
> >>
> >> When Linux is used as a router, it is undesirable for the kernel to process
> >> incoming packets when the address assigned to the interface is down.
> >> The initial problem report was for a management application that used ICMP
> >> to check link availability.
> >>
> >> The default is disabled to maintain compatibility with previous behavior.
> >> This is not recommended for server systems because it makes fail over more
> >> difficult, and does not account for configurations where multiple interfaces
> >> have the same IP address.
> >>
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > Ping David et. all?
> > I too want this.
>
> Doesn't arpfilter enable this already? If you set in on the still up
> interfaces those will not answer to other IP addresses.
>
> This only works on the ARP level, so it has to wait until the arp
> cache in the remote host times out.

I tried that but it didn't work, but I didn't think of clearing
the ARP cache.
Anyhow, such methods seems worse than just doing ifconfig 0.0.0.0

  Jocke

