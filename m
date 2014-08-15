From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Thu, 14 Aug 2014 22:02:27 -0700
Message-ID: <0B7AA838-0FC7-4B0C-881E-17FC71748140@alum.mit.edu>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com> <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com> <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com> <1408064641.867439.152913861.09367C24@webmail.messagingengine.com> <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:57519 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887AbaHOFCl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 01:02:41 -0400
In-Reply-To: <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 14, 2014, at 7:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I believe I am going to implement 2)  (clamp the snaplen)

If you mean "a packet that's too big to fit into a single block will be cut off at the size of the block, even if the user-requested snaplen is bigger than that", I, at least, have no problem whatsoever with that from libpcap's point of view.  We, the libpcap developers, could just boost the maximum snaplen if necessary.  (Disclaimer: I don't speak for all developers or users of libpcap.)