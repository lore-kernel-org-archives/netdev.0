From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Deadlock in af_packet/packet_rcv
Date: Tue, 30 Nov 2004 13:07:11 -0800
Message-ID: <20041130130711.5524a935.davem@davemloft.net>
References: <20041125205503.GA18083@suse.de>
	<41AC3E2F.2030003@tpack.net>
	<20041130110110.GD16970@suse.de>
	<41AC5A26.6000400@tpack.net>
	<20041130114535.GF16970@suse.de>
	<41AC5FEE.8020707@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41AC5FEE.8020707@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2004 12:56:30 +0100
Tommy Christensen <tommy.christensen@tpack.net> wrote:

> > i.e. there's no local_bh_disable at all - adding the local_bh_disable
> > was the whole point of my patch. Or did you refer to a different spinlock?
> 
> The local_bh_disable() is called earlier in dev_queue_xmit(), and
> is held across the whole HARD_TX_LOCK/dev_queue_xmit_nit/
> hard_start_xmit/HARD_TX_UNLOCK sequence.

He's right.  There must be something else happening in your
tree Olaf.
