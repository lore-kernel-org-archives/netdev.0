From: "Zheng Jianping" <zjp@iscas.ac.cn>
Subject: How to get the IPv6 address of next hop  towards destination?
Date: Fri, 29 Nov 2002 12:13:13 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000d01c2975d$a2ad3c10$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Pedro Roque" <roque@di.fc.ul.pt>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm modifying the Linux kernel (2.4.7.10) to support IPv6 multicast
forwarding. As required by IPv6 multicast routing protocol, the IPv6 address
of next hop towards destination is needed. So how can I get this
information?

Calling  struct dst_entry * ip6_route_output(struct sock *sk, struct flowi
*fl)
can get dst_entry which has a member
    struct neighbour *neighbour;
But I don't know which member in 'struct neighbor' stores the IPv6 address.
It seems  that
  u8   primary_key[0];
is responsible for it.

Is it right?

Thanks,
Zheng Jianping

----------------------------------------------------------------------------
---------------------------
Multimedia Communication & Network Engneering Research Center
Institue of Software, Chiese Academy of Sciences

Email: zjp@iscas.ac.cn
Tel:     6255,5523
