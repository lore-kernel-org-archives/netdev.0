From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 7 Oct 2008 16:06:03 +0200
Message-ID: <20081007160603.0db7e967@speedy>
References: <20081006202401.14f03be2@speedy>
	<200810071520.56610.denys@visp.net.lb>
	<20081007124820.GG4606@ntm.vs.lam.cz>
	<200810071549.16647.denys@visp.net.lb>
	<48EB5C63.60501@trash.net>
	<20081007132800.GH4606@ntm.vs.lam.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53417 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbYJGOGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 10:06:10 -0400
In-Reply-To: <20081007132800.GH4606@ntm.vs.lam.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Oct 2008 15:28:02 +0200
Milan Kocian <milon@wq.cz> wrote:

> On Tue, Oct 07, 2008 at 02:56:03PM +0200, Patrick McHardy wrote:
> > Denys Fedoryshchenko wrote:
> >> On Tuesday 07 October 2008, Milan Kocian wrote:
> >>> hello,
> >>>
> >>> btw. How can I see vlan id on device ?
> >>> After:
> >>> # ip l a l eth0 type vlan id 100
> >>> # ip a
> >>> I see:
> >>>
> >>> 64: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> >>>     link/ether 00:16:d3:3e:4e:b9 brd ff:ff:ff:ff:ff:ff
> >>>
> >>> No vlan id in interface name ?
> >>>
> >>> # ip -V
> >>> ip utility, iproute2-ss080725
> >>>
> >>> regards,
> >> Use flag -d
> >> rich ip # ./ip -d l show dev vlan0
> >> 31: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> >>     link/ether 00:1e:8c:89:78:af brd ff:ff:ff:ff:ff:ff
> >>     vlan id 100 <REORDER_HDR>
> >
> > It would be better to have -d as a default, I was afraid of breaking
> > scripts of people sedding and awking around with the iproute output.
> >
> > Stephen should make this call, I'm not sure what guarantees he wants
> > to provide. I just remembered one of my previous jobs where a large
> > number of scripts had to be changed because iproute started using
> > lower case letters in some spots, and I had to do it :)
> 
> Thanks for quick answer. 
> Yes, -d will be fine.
> It is a pity that vlan id will not be in interface name. It was 
> comfortable to have vlan id in interface name. 
> Any reason for changing naming schema ?
> 
> regards,
> 
> -- 
> Milan Kocian

It should always show type information (ie vlan etc).
Scripts that can't take extra lines might break even with -d since they might have
been using that already.  As long as new information appears after old, it should
be okay.
