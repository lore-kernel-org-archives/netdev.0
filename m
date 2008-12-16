From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: kernel panics with net_rx_action on kernels >2.6.26
Date: Tue, 16 Dec 2008 06:59:01 +0000
Message-ID: <20081216065901.GA4510@ff.dom.local>
References: <20081215133521.GA6697@ff.dom.local> <4946B9DD.9010105@sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexander Huemer <alexander.huemer@sbg.ac.at>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4946B9DD.9010105@sbg.ac.at>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 15, 2008 at 09:11:09PM +0100, Alexander Huemer wrote:
...
> i applied it to 2.6.28-rc8.
> the machine is already running under heavy network load, as before, when
> the panics occur.
> heavy load means high packets/second values, not high byte/second values.
> if you find that necessary for testing i will find a way to pump some
> gigs through the machine.
> let's see what happens.

Actually, the bug I trie to fix in this patch doesn't depend on heavy
load directly, but on counting: it should trigger after receiving 20
packets (or max_interrupt_work driver parameter if you use this), and
then some break.

> i will get back to you after a new panic or 2 days without panic.

Regards,
Jarek P.
