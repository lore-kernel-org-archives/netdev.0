From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.4/2.6 PATCHES] Change some ip_fragment checks to help IPVS
Date: Wed, 15 Oct 2003 10:01:29 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310150930510.1199-100000@u.domain.uli>
References: <20031014155152.275270c1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <wensong@linux-vs.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031014155152.275270c1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 14 Oct 2003, David S. Miller wrote:

> > 	One related question: is ip_fragment() backport from 2.6
> > to 2.4 planned?
>
> No, it only makes sense in the 2.6.x stack.
>
> 2.4.x and 2.6.x networking are wildly different beasts and
> you'll therefore need to make the IPVS implementation cope
> with that in each tree.

	ok. But my subject is wrong. In fact, it covers
the general case of forwarded packets after calling ip_defrag.
It means, for example, that if ip_conntrack is running in 2.4 then all 
packets with total_length>mtu are refragmented or linearized. This 
includes the case with 60k packets containing frags where each frag fits
in mtu. But I see, it is a dangerous place to change.

Regards

--
Julian Anastasov <ja@ssi.bg>
