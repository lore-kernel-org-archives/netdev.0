From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Wed, 06 Jan 2010 15:17:22 +0100
Message-ID: <1262787442.22735.10.camel@jdb-workstation>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>
	 <4B4427CE.1040203@gmail.com> <1262771369.9474.80.camel@jdb-workstation>
	 <20100106232231.5f454d53@opy.nosense.org>
Reply-To: hawk@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:38540 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab0AFOMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 09:12:37 -0500
In-Reply-To: <20100106232231.5f454d53@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-01-06 at 23:22 +1030, Mark Smith wrote:
> On Wed, 06 Jan 2010 10:49:29 +0100
> Jesper Dangaard Brouer <hawk@comx.dk> wrote:
> > 
> > This patch solved the issue by doing proxy arp'ing on the router against
> > the "local" network, thus making it possible for customers to
> > communicate, but via the router.  This also gives the ability to do
> > firewalling on the router between customers on an Ethernet. (In our
> > solution the Linux router also have a personal firewall configurable per
> > customer.)
> > 
> 
> I can see value in that - you're forcing all traffic through the
> upstream router for policy enforcement purposes, without having to have
> point-to-point (simulated or otherwise) links between customers and the
> router, and avoiding IP address waste by not using /30s. You're pretty
> much making the ethernet a Non-broadcast Multi-Access link.

Yes, its actually a quite nice trick, and several switch vendors have
supported this technology for years (although they all annoying call it
something differently).  And we/ComX have actually also been using this
for years, including my patch (sorry for being so slow with upstream
submission).

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

