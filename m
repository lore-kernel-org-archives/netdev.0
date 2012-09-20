From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Thu, 20 Sep 2012 12:21:56 -0400
Message-ID: <20120920122156.44cbfd59.billfink@mindspring.com>
References: <1347908305-13541-1-git-send-email-brutus@google.com>
	<1347913239.26523.173.camel@edumazet-glaptop>
	<20120919.163406.487082174277409074.davem@davemloft.net>
	<1348088634.31352.26.camel@edumazet-glaptop>
	<CAEkNxbEJjAu3+3yDGPGSzzee-LY_797RdNbBgcC6=-aDHfEAJQ@mail.gmail.com>
	<505AFDE9.4080602@earthlink.net>
	<1348141871.31352.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sclark46@earthlink.net, Bruce Curtis <brutus@google.com>,
	David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:52733 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751484Ab2ITRar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 13:30:47 -0400
In-Reply-To: <1348141871.31352.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Sep 2012, Eric Dumazet wrote:

> On Thu, 2012-09-20 at 07:28 -0400, Stephen Clark wrote:
> >  
> > Does this mean traffic on the loopback interface will not traverse 
> > netfilter?
> > 
> 
> Yes this was already mentioned.
> 
> Only the SYN / SYNACK messages will
> 
> All data will bypass IP stack, qdisc (if any), loopback driver, and
> netfilter.

These restrictions and any others should be documented in ip-sysctl.txt.

>From Eric's earlier e-mail:

-> no iptables, 
   no qdisc (by default there is no qdisc on lo),
   no loopback stats (ifconfig lo).
   some SNMP stats missing as well (netstat -s)

						-Bill
