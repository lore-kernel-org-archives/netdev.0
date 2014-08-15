From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 06:19:32 -0400
Message-ID: <20140815101932.GA26489@hmsreliant.think-freely.org>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
 <1408063859.864295.152910193.45470221@webmail.messagingengine.com>
 <1408064180.6804.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60742 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbaHOKTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 06:19:42 -0400
Content-Disposition: inline
In-Reply-To: <1408064180.6804.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 05:56:20PM -0700, Eric Dumazet wrote:
> On Fri, 2014-08-15 at 02:50 +0200, Hannes Frederic Sowa wrote:
> 
> > 5) Or let a setsockopt control the NETIF_F_GRO bit of an interface if it
> > is bound to it? This will likely result in an implementation where we
> > must count current TPACKET_V3 sockets disabling GRO on an interface,
> > much like promisc counter.
> 
> loopback interface has MTU = 64K, it looks like the problem is not tied
> to GRO.
> 
Can we add a listener to the af packet code to resize the block length of the
socket based on the MTU?  

I realize that overloads user configuration, but if we warn them...

Neil
> 
> 
