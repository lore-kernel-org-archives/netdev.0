From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 09:57:31 +0000
Message-ID: <20091113095731.GA7749@ff.dom.local>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com> <20091113074508.GA6605@ff.dom.local> <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com> <20091113091825.GA7449@ff.dom.local> <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:61559 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755606AbZKMJ5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 04:57:31 -0500
Received: by fxm21 with SMTP id 21so243649fxm.21
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 01:57:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 05:38:56PM +0800, Changli Gao wrote:
> On Fri, Nov 13, 2009 at 5:18 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > I'm mostly concerned with routers doing forwarding with 1Gb or 10Gb
> > NICs (including multiqueue). Alas/happily I don't have such a problem,
> > but can't help you with testing either.
> >
> 
> Oh, :) . I know more than one companies use kernel threads to forward
> packets, and there isn't explicit extra overhead at all. And as you
> know, as throughput increases, NAPI will bind the NIC to a CPU, and
> softirqd will be waked up to do the work, which should be done in
> SoftIRQ context. At that time, there isn't any difference between my
> approach and the current kernel's.

I'm not against your solution at all. It only needs more proof... You
seem to forget the main networking paths now are just softirq, and
it's probably for some reason. If kernel threads are good enough, it
seems we should do more such changes.

Jarek P.
