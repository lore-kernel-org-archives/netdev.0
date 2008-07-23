From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Wed, 23 Jul 2008 22:43:35 +0200
Message-ID: <20080723204335.GA14788@ami.dom.local>
References: <1216810696.7257.175.camel@twins> <20080723113519.GE4561@ff.dom.local> <20080723114914.GF4561@ff.dom.local> <20080723.131607.79681752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peterz@infradead.org, Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755395AbYGWUnG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080723.131607.79681752.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2008 at 01:16:07PM -0700, David Miller wrote:
...
> There will always be a need for a "stop all the TX queues" operation.

The question is if the current way is "all correct". As a matter of
fact I think Peter's doubts could be justified: taking "USHORT_MAX"
locks looks really dubious (so maybe it's not so strange lockdep
didn't get used to this).

Jarek P.
