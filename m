From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]behavior of ip6_route_input() for link local address.
Date: Fri, 21 Oct 2005 17:27:09 +0900 (JST)
Message-ID: <20051021.172709.47930126.yoshfuji@linux-ipv6.org>
References: <43572256.40101@21cn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932556AbVJUI1M@vger.kernel.org>
To: yanzheng@21cn.com, davem@davemloft.net
In-Reply-To: <43572256.40101@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <43572256.40101@21cn.com> (at Thu, 20 Oct 2005 12:51:34 +0800), Yan Zheng <yanzheng@21cn.com> says:

> I find that linux will reply echo request destined to an address which belongs to an interface other than the one from which the request received.
> This behavior doesn't make sense for link local address.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Please note that sender does need to setup neighbor
entry by hand to reproduce this bug.
(Link-local address on eth1 is not visible on eth0,
from the point of view of neighbor discovery in IPv6.)

 +--------+               +--------+
 | sender |               | router |
 +---+----+               +-+----+-+
     |eth0              eth0|    |eth1
-----+----------------------+-  -+--------------

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
