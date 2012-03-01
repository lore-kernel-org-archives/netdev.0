From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/10] af_unix: add multicast and filtering features to AF_UNIX
Date: Thu, 1 Mar 2012 12:33:14 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com>
References: <1330604802.2465.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	<rodrigo.moya@collabora.co.uk>, <javier@collabora.co.uk>,
	<lennart@poettering.net>, <kay.sievers@vrfy.org>,
	<alban.crequy@collabora.co.uk>, <bart.cerneels@collabora.co.uk>,
	<sjoerd.simons@collabora.co.uk>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Javier Martinez Canillas" <javier.martinez@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1330604802.2465.43.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> > So, now we are trying a different approach. To create a new address
> > family AF_MCAST. That way we can have more control over the
semantics of
> > the socket interface for that family.
> > 
> > We expect to have some patches in a few days and we will resend.
> > 
> > Does this makes more sense to you?
> > 
> 
> Why adding an obscure set of IPC mechanism in network tree, and not
> using (maybe extending) traditional IPC (Messages queues, semaphores,
> Shared memory, pipes, futexes, ...).

If it isn't a totally silly suggestion, why not write a simple
device driver that just does what you want?
Which (I think) is named pipes with multiple readers.

	David
