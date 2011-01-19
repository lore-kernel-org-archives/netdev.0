From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Wed, 19 Jan 2011 17:18:31 +0100
Message-ID: <20110119161831.GA1845@del.dom.local>
References: <4D336050.9030602@netfilter.org>
 <20110118093811.GA7520@ff.dom.local>
 <20110118.020702.115924992.davem@davemloft.net>
 <20110118102437.GB7520@ff.dom.local>
 <4D35F8A3.1010600@netfilter.org>
 <20110118211450.GC4288@del.dom.local>
 <4D36FADD.8000405@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47050 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab1ASQSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 11:18:38 -0500
Received: by fxm20 with SMTP id 20so1045702fxm.19
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 08:18:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D36FADD.8000405@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 03:53:17PM +0100, Pablo Neira Ayuso wrote:
> On 18/01/11 22:14, Jarek Poplawski wrote:
...
> > BTW, could you answer my earlier question, why NLM_F_ATOMIC flag isn't
> > handled now with dumps?
> 
> The NLM_F_ATOMIC flag is not affected, the netlink header is still
> passed to netlink_dump_start() so you can check for it in the callback
> to start an atomic dump.

Right! I had some blackout, sorry.

Jarek P.
