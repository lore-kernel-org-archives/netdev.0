From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Wed, 11 Feb 2004 16:53:20 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402111643090.2809-100000@l>
References: <1076506090.2268.252.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1076506090.2268.252.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On 11 Feb 2004, jamal wrote:

> I agree with you. We may be saying the same thing. What i mean is [**]:
> further below.

	Yes, we better to talks with source code :)

> [**] If a linux machine (which is sane ARP implementation) sent a unicast
> probe to us, theres high likelihood that the target is in VALID state.
> This is what i refered to as an educated guess.

	Ah, this is not true :) Sane requestor as Linux will switch
forever between STALE (delay+probe) and REACHABLE if target is STALE
and we answer to these unicast requests without updating the
target's state, for example, if there is only ARP traffic. In
normal usage it can not occur but if someone is sending
unicast requests without IP traffic we will hit it. IIRC, old
arping versions do exactly this, 1 brd + many unicasts.

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
