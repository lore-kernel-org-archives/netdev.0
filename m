From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Thu, 14 Aug 2014 17:56:20 -0700
Message-ID: <1408064180.6804.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
	 <1408063859.864295.152910193.45470221@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:54753 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaHOA4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 20:56:22 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so2481561pdj.40
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 17:56:22 -0700 (PDT)
In-Reply-To: <1408063859.864295.152910193.45470221@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-15 at 02:50 +0200, Hannes Frederic Sowa wrote:

> 5) Or let a setsockopt control the NETIF_F_GRO bit of an interface if it
> is bound to it? This will likely result in an implementation where we
> must count current TPACKET_V3 sockets disabling GRO on an interface,
> much like promisc counter.

loopback interface has MTU = 64K, it looks like the problem is not tied
to GRO.
