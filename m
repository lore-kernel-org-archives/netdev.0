From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Thu, 20 Sep 2012 09:29:02 +0200
Message-ID: <1348126142.2761.172.camel@localhost>
References: <1347357081.3928.32.camel@localhost>
	  <20120912213627.GJ14750@breakpoint.cc> <20120914120750.GA5764@1984>
	  <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
	 <1348058791.2761.94.camel@localhost>
	 <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@gnumonks.org>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139Ab2ITH3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 03:29:17 -0400
In-Reply-To: <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 08:57 +0200, Patrick McHardy wrote:
> On Wed, 19 Sep 2012, Jesper Dangaard Brouer wrote:
> 
> > On Fri, 2012-09-14 at 15:15 +0200, Patrick McHardy wrote:
> >> On Fri, 14 Sep 2012, Pablo Neira Ayuso wrote:
> >>
> > [...cut...]
> >>>> Patrick, any other idea?
> >>>
> > [...cut...]
[... (hair)cut(?)...]

> > No it does not work :-(
> 
> Ok I think I understand the problem now, we're invoking the NAT cleanup
> callback twice with clean->hash = true, once for each direction of the
> conntrack.
> 
> Does this patch fix the problem?

Yes, it fixes the problem :-)

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
