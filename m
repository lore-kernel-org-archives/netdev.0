From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Sun, 10 May 2015 20:24:14 +0200
Message-ID: <20150510182414.GA4198@salvia>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org>
 <1431277170-4618-3-git-send-email-pablo@netfilter.org>
 <554F9946.9040707@plumgrid.com>
 <20150510175934.GA3799@salvia>
 <554F9DE8.3000507@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46683 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795AbbEJSTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 14:19:31 -0400
Content-Disposition: inline
In-Reply-To: <554F9DE8.3000507@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 11:05:28AM -0700, Alexei Starovoitov wrote:
> On 5/10/15 10:59 AM, Pablo Neira Ayuso wrote:
> >No, Daniel is *not* benchmarking the netif_received_core() with no
> >filtering at all.
> 
> sorry, not true. We did benchmark all combinations. Daniel posted
> his, I'll send numbers from my box as well.

Daniel said:

"The extra indirection layers however, are not necessary for calling
into ingress qdisc. pktgen calling locally into netif_receive_skb()
with a dummy u32, single CPU result on a Supermicro X10SLM-F, Xeon
E3-1240: before ~21,1 Mpps, after patch ~22,9 Mpps."

That explicitly refers to u32, hence qdisc ingress, so he did *not*
post any number of the use case I'm indicating.
