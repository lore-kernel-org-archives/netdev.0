From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next PATCH V1 0/9] net: fragmentation performance
 scalability on NUMA/SMP systems
Date: Sun, 25 Nov 2012 08:11:31 -0800
Message-ID: <1353859891.30446.634.camel@edumazet-glaptop>
References: <20121123130749.18764.25962.stgit@dragon>
	 <1353810665.2590.4774.camel@edumazet-glaptop>
	 <1353833627.11754.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35074 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab2KYQLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 11:11:34 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so5214340iea.19
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2012 08:11:34 -0800 (PST)
In-Reply-To: <1353833627.11754.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-11-25 at 09:53 +0100, Jesper Dangaard Brouer wrote:

> Yes, for the default large 64k packets size, its just a "fake"
> benchmark.  And notice with my fixes, we are even faster than the
> none-frag/single-UDP packet case... but its because we are getting a
> GSO/GRO effect.

Could you elaborate on this GSO/GRO effect ?
