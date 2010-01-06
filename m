From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Thu, 7 Jan 2010 01:05:24 +1030
Message-ID: <20100107010524.6f577367@opy.nosense.org>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>
	<4B4427CE.1040203@gmail.com>
	<1262771369.9474.80.camel@jdb-workstation>
	<20100106232231.5f454d53@opy.nosense.org>
	<1262787442.22735.10.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:53648 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932229Ab0AFOfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 09:35:32 -0500
In-Reply-To: <1262787442.22735.10.camel@jdb-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Jan 2010 15:17:22 +0100
Jesper Dangaard Brouer <hawk@comx.dk> wrote:

> On Wed, 2010-01-06 at 23:22 +1030, Mark Smith wrote:
> > On Wed, 06 Jan 2010 10:49:29 +0100
> > Jesper Dangaard Brouer <hawk@comx.dk> wrote:
> > > 
> > > This patch solved the issue by doing proxy arp'ing on the router against
> > > the "local" network, thus making it possible for customers to
> > > communicate, but via the router.  This also gives the ability to do
> > > firewalling on the router between customers on an Ethernet. (In our
> > > solution the Linux router also have a personal firewall configurable per
> > > customer.)
> > > 
> > 
> > I can see value in that - you're forcing all traffic through the
> > upstream router for policy enforcement purposes, without having to have
> > point-to-point (simulated or otherwise) links between customers and the
> > router, and avoiding IP address waste by not using /30s. You're pretty
> > much making the ethernet a Non-broadcast Multi-Access link.
> 
> Yes, its actually a quite nice trick, and several switch vendors have
> supported this technology for years (although they all annoying call it
> something differently).  And we/ComX have actually also been using this
> for years, including my patch (sorry for being so slow with upstream
> submission).
> 

Do you have any issues with router redundance e.g. VRRP? I can't really
think of any, as long as the proxy-arp responses are using the VRRP
virtual router address, rather than the actual NIC's address, and the
routers can see each other via the switch.

> -- 
> Med venlig hilsen / Best regards
>   Jesper Brouer
>   ComX Networks A/S
>   Linux Network Kernel Developer
>   Cand. Scient Datalog / MSc.CS
>   Author of http://adsl-optimizer.dk
>   LinkedIn: http://www.linkedin.com/in/brouer
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
