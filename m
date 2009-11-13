From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 12:32:03 +0000
Message-ID: <20091113123203.GA8648@ff.dom.local>
References: <412e6f7f0911122216u6880e855g6a15dac29ad6a100@mail.gmail.com> <20091113074508.GA6605@ff.dom.local> <412e6f7f0911130054i7a508a6ah16368f11bdc7353d@mail.gmail.com> <20091113091825.GA7449@ff.dom.local> <412e6f7f0911130138td181935w36cab3119972753e@mail.gmail.com> <20091113095731.GA7749@ff.dom.local> <412e6f7f0911130325r20e2fbbbg21e2e384de1f7c0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:42406 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbZKMMcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 07:32:03 -0500
Received: by fg-out-1718.google.com with SMTP id d23so207775fga.1
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 04:32:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911130325r20e2fbbbg21e2e384de1f7c0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 07:25:33PM +0800, Changli Gao wrote:
> I find there is still a softirqd kernel thread for each online CPU,
> and these threads will be waked up if there are more SoftIRQs need to
> be done after restarting the SoftIRQ processing many times, to keep
> the whole system responsible. Did I miss sth.? And at the other side,
> real time branch just wants to make all the activities based on kernel
> threads, even ISR.

I wish them well! But again: for some strange reason network admins,
who sometimes care to complain here, rarely (very rarely) mention this
RT branch... (Actually, I recall only one case, and it probably wasn't
even real admin ;-)

Jarek P.

