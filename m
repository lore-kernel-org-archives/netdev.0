From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sat, 19 Feb 2005 21:23:04 +0900 (JST)
Message-ID: <20050219.212304.08460936.yoshfuji@linux-ipv6.org>
References: <4217266F.6090700@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
To: kaber@trash.net, davem@davemloft.net
In-Reply-To: <4217266F.6090700@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4217266F.6090700@trash.net> (at Sat, 19 Feb 2005 12:43:43 +0100), Patrick McHardy <kaber@trash.net> says:

> The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
> of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
> type and code should be stored in sport and dport, in struct flowi both
> are contained in fl_ip_sport.

I agree.

--yoshfuji
