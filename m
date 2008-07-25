From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Fri, 25 Jul 2008 20:02:28 +0200
Message-ID: <20080725180227.GB3005@ami.dom.local>
References: <20080719233506.12596.59935.stgit@fate.lan> <20080725105748.GB10399@ff.dom.local> <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local> <20080725152932.93641c4o5qk1sx0g@hayate.ip6> <20080725125414.GB25369@ff.dom.local> <20080725161503.67994cpfp4jouz7k@hayate.ip6> <20080725174644.GA3005@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:1510 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbYGYSCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 14:02:13 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1298137nfc.21
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 11:02:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080725174644.GA3005@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 07:46:44PM +0200, Jarek Poplawski wrote:
...
> But, if it's really
> necessary here, IMHO, it should be done "clean" way, like additional
> parameter(s) to qdisc_enqueue(), because in cases like NET_XMIT_CN we
> don't even know what happened with an skb.

...And, we should consider that in such cases, even if it's possible
to find this out, it could additionally complicate algorithms.

Jarek P.
