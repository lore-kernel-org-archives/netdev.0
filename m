From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port
Date: Thu, 03 Oct 2002 23:15:34 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.231534.83777766.yoshfuji@linux-ipv6.org>
References: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
	<200210031301.RAA29267@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200210031301.RAA29267@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200210031301.RAA29267@sex.inr.ac.ru> (at Thu, 3 Oct 2002 17:01:11 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> While doing *_get_port() daddr/dport are _unknown_ and always zero,
> so it never works.
> 
> Please, remove these bits, the patch will become simpler.

Ok, I'll do that.


> What's about the problem, it cannot be a problem for TCP, connection
> uniqueness is verified by tcp_*_check_established() not depending
> on value of SO_REUSEADDR. What's about UDP, the problem really might
> be a real problem, let's defer the issue, it looks absoluteky unrelated.

Hmm, but I'm afraid that different behavior between TCP and UDP would
confuse users.


> BTW the question: why is bindv6only in device configuration directory?

Because I thought that net.ipv6.conf is the place for all 
configuration...

Do you propose to move it to parent directory (net.ipv6.bindv6only),
and put other general settings there?

--yoshfuji
