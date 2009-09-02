From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: reuse struct sock fields
Date: Tue, 01 Sep 2009 17:44:28 -0700 (PDT)
Message-ID: <20090901.174428.255093067.davem@davemloft.net>
References: <20090830170442.GA3482@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.s.tsirkin@gmail.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40468
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755444AbZIBAoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:44:14 -0400
In-Reply-To: <20090830170442.GA3482@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 30 Aug 2009 20:04:42 +0300

> As tun always has an embeedded struct sock,
> use sk and sk_receive_queue fields instead of
> duplicating them in tun_struct.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
