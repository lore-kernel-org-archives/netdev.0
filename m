From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH V1 1/9] net: frag evictor, avoid killing
 warm frag queues
Date: Sat, 24 Nov 2012 12:36:52 +0100
Message-ID: <1353757012.11754.110.camel@localhost>
References: <20121123130749.18764.25962.stgit@dragon>
	 <20121123130806.18764.41854.stgit@dragon>
	 <20121123195815.GA32625@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183Ab2KXLjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Nov 2012 06:39:09 -0500
In-Reply-To: <20121123195815.GA32625@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-23 at 20:58 +0100, Florian Westphal wrote:
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > +// TODO: Idea what about also looking at flag INET_FRAG_FIRST_IN
> > +// just as safe-guard against frags with a dropped "head" packet
> > +		if (!force && q->creation_ts == (u32) jiffies) {
> 
> I think we should not rely on head fragment arriving first.

Good point.  Lets keep the current approach.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
