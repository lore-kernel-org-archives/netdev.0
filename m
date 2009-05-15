From: "Alexander V. Lukyanov" <lav@netis.ru>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Fri, 15 May 2009 11:19:46 +0400
Message-ID: <20090515071946.GA15669@night.netis.ru>
References: <20090422055735.GA4334@night.netis.ru> <20090427054103.GA27529@night.netis.ru> <20090428125755.GA5242@night.netis.ru> <49F76BF6.4040709@gmail.com> <20090429054510.GA8267@night.netis.ru> <20090429090809.GA2995@ami.dom.local> <20090508062640.GA4555@night.netis.ru> <20090508104628.GA6287@ff.dom.local> <20090510073559.GA8929@night.netis.ru> <20090510124641.GA2978@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from night.yars.free.net ([193.233.48.54]:44106 "EHLO
	night.yars.free.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbZEOHUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 03:20:01 -0400
Content-Disposition: inline
In-Reply-To: <20090510124641.GA2978@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2009 at 02:46:41PM +0200, Jarek Poplawski wrote:
> On Sun, May 10, 2009 at 11:35:59AM +0400, Alexander V. Lukyanov wrote:
> > On Fri, May 08, 2009 at 10:46:28AM +0000, Jarek Poplawski wrote:
> > > I can't see anything suspicious for now, except these UDP and TCP
> > > warnings. Did you see similar messages with 2.6.27? Btw., could this
> > 
> > Yes. Such messages show up with any kernel version.
> > 
> > > eth0.987 be "connected" with any of this traffic? (IP# ?)
> > 
> > No, eth0.987 is only used for traffic output.
> > 
> > BTW, it seems that only actively used vlan interfaces have the problem
> > (even when the traffic stops). Other vlan interfaces with little traffic
> > can be removed with no problems.
> 
> OK, I'll try to look around this, but how about trying 2.6.28.10 in
> the meantime? It could limit "a bit" the number of places/lines.

Looks like 2.6.28.10 does not have this refcnt problem. Also, after I have
reversed net/ipv4/route.c changes from 2.6.29, the problem does not occur either.

-- 
   Alexander..
