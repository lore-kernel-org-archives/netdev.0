From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: linux-2.4.21 and IPv6: problem solved
Date: Sun, 17 Aug 2003 23:38:37 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817.233837.101383706.yoshfuji@linux-ipv6.org>
References: <20030817152725.A2212@keun>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: szukw000@students.uni-mainz.de
In-Reply-To: <20030817152725.A2212@keun>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030817152725.A2212@keun> (at Sun, 17 Aug 2003 15:27:25 GMT), "w.szukalski" <szukw000@students.uni-mainz.de> says:

> First I regret: I did not mention the socket creation:
> 
> 	reader = socket(AF_INET6, SOCK_DGRAM, PF_UNSPEC);
> 	writer = socket(AF_INET6, SOCK_DGRAM, PF_UNSPEC);
                                              ~~~~~~~~~This is not good. use 0, or IPPROTO_UDP (for UDP).

--yoshfuji
