From: "Denys" <denys@visp.net.lb>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 4 Apr 2007 05:11:37 +0300
Message-ID: <20070404020622.M69215@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb> <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:35257 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966287AbXDDCSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 22:18:42 -0400
In-Reply-To: <461301C0.2050409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think this highly useful feature given by jamal, difficult to be avoided 
from crash, if user not enough experienced in networking(like me). I guess 
packet can be even not ipv4/ipv6 packet, maybe it can be cloned IPX or ARP, 
so TTL field cannot be used. I checked maybe sk_buff have some fields, seems 
also bad luck, if there can be something like "internal" counter for packet, 
how much times it got redirected, it will help. But in my case of VLAN's it 
is really my own mistake and difficult to avoid it. Only bad thing - machine 
got completely locked up, and if it is remote system - it will not oops/or 
reboot even. But i dont have any idea in mind how to avoid this, only than 
big warning in DOC and internal iproute2 help :-)

On Wed, 04 Apr 2007 03:39:12 +0200, Patrick McHardy wrote
> jamal wrote:
> > On Wed, 2007-04-04 at 03:03 +0300, Denys wrote:
> > 
> >>I'm not sure it is mistake or error, but i feel it is dangerous, cause 
> >>commands locking up the system, no kernel panic, no oops, so only 
watchdog 
> >>can save poor server (and not sure this even)
> >>
> >>Commands to lockup system (just i am giving my example, i didnt sort out 
what 
> >>exactly locked up system, i guess redirecting to eth0.5, which is not 
> >>intended for that):
> > 
> > 
> > read:
> > doc/actions/mirred-usage
> 
> Are you refering to "What NOT to do if you dont want your machine to
> crash:"? I think we should make sure users can't even accidentally
> crash their box, so this should at least be caught at runtime.
> I thought the TTL stuff was intended to avoid this ..
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

