From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] udp: increment UDP_MIB_NOPORTS in mcast receive
Date: Wed, 3 Oct 2012 08:45:55 -0400
Message-ID: <OFA39D9FC0.CDC6EE41-ON85257A8C.00458030-85257A8C.00461EF4@us.ibm.com>
References: <506955F3.8050304@googlemail.com>	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>	 <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg> <1349249328.12401.1364.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: chris2553@googlemail.com, Dave Jones <davej@redhat.com>,
	David Miller <davem@davemloft.net>, gpiez@web.de,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:45528 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab2JCMqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 08:46:03 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 3 Oct 2012 06:46:02 -0600
In-Reply-To: <1349249328.12401.1364.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 10/03/2012 03:28:48 AM:
 
> BTW, it seems we dont properly increase UDP MIB counters when a
> multicast message is not delivered to at least one socket.

If an interface is in promiscuous mode or there are false
positives in a multicast address filter, wouldn't this count as
"drops" packets that were never intended for this machine?

I think an otherwise valid multicast or broadcast packet that doesn't
have a local receiver is not an error and shouldn't be counted.

                                                        +-DLS
