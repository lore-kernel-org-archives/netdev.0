From: Julian Anastasov <ja@ssi.bg>
Subject: Re: send-to-self (was Re: routing bug report for 2.4)
Date: Mon, 30 Jun 2003 13:43:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306301224330.1541-100000@l>
References: <3EFFEDD7.5020205@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EFFEDD7.5020205@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 30 Jun 2003, Ben Greear wrote:

> > I'm avoiding the arp_filter changes. The setup uses
> > asymmetric routing so better use arp_filter=0 or other
>
> arp_filter=1, right?

	Right, my mistake, the routing is symmetric, arp_filter=1
is even recommended. Only rp_filter=1 can not be used as ARP
filter but you can use rp_filter=1 for IP filtering.

> I want to avoid strange(r) routing configurations, as I'm already
> using lots of routing tricks, and don't want to confuse matters
> more.  I also turn on arp filtering to ensure the arps go out the
> right interface currently.

	Right, you need just to bind to src IP (may be you can
avoid even that if you replace the prefsrc in your local routes).

> You should be able to easily test most of the changes your code
> if you have a machine with two ethernet interfaces and a loopback
> cable...

	That is the problem, no 2.4 host with 2 NICs. Not soon.

Regards

--
Julian Anastasov <ja@ssi.bg>
