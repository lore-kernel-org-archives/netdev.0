From: "David S. Miller" <davem@redhat.com>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Mon, 9 Feb 2004 15:10:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209151053.1f63937a.davem@redhat.com>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
	<20040209140853.69ab8bea.davem@redhat.com>
	<Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2004 01:06:15 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> As for IPVS like setups, the requirements need per IP tunning which
> is possible only with some kind of filtering, not a global flag,
> especially for the input device. Note that the "hidden" flag
> is checked for the target device, this was the only way to
> differentiate by device. May be this is a proof arp_announce is
> not for IPVS :) It is mostly to work with other stacks because
> I'm flooded with emails about how Linux ARP can be more friendly.

So this new 'arp_announce' change suggestion will preempt any need for
hidden and make everyone happy?

About output_route vs. inet_select_addr(), probably the latter is better.
Your goal is to differentiate between primary and seconday addrs on a device
right?  Route lookup is also more expensive, probably.
