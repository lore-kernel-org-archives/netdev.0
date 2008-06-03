From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 3 Jun 2008 11:34:11 -0700
Message-ID: <20080603113411.0af753d8@extreme>
References: <20080604.022836.31952523.yoshfuji@linux-ipv6.org>
	<20080603.103059.193720094.davem@davemloft.net>
	<20080603104640.21026cdb@extreme>
	<20080603.105308.196677970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39005 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754570AbYFCSeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 14:34:17 -0400
In-Reply-To: <20080603.105308.196677970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Jun 2008 10:53:08 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 3 Jun 2008 10:46:40 -0700
> 
> > It is not what desktop users want, that is why it is a dynamic configuration
> > option via /proc/sys/net/ipv6/conf/ethX/link_detect.
> > 
> > But it is what a router wants. So why not allow it? Obviously, Vyatta
> > users expect systems behave same as Cisco.
> > 
> > The problem with doing it all in user space are not impossible just more difficult:
> >   * links bouncing lead to synchronization problems
> >   * existing Quagga code avoids messing with "system routes" 
> >   * Quagga has to be portable to Solaris/BSD etc..
> > 
> > More at:
> > http://osdir.com/ml/network.quagga.devel/2004-08/msg00009.html
> 
> If it's a route behavioral attribute, make it as such and add
> a new rtnetlink route attribute.  If it's not there, existing
> behavior is maintained.
> 

How would this work for system generated routes which occur
when address is added to interface?
