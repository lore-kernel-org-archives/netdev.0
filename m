From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next] NDISC Updates (sender-side clean-up)
Date: Tue, 18 Dec 2012 05:46:29 +0900
Message-ID: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:55692 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752143Ab2LQUqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 15:46:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Please consider pulling
        git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-next.git
net-next-20121218_ndisc
for net-next; it mainly cleans up sender side of NDISC subsystem.

--yoshfuji

[CHANGELOG]

YOSHIFUJI Hideaki (17):
      ndisc: Fix size calculation for headers.
      ipv6: Introduce __ip6_hdr() for setting IPv6 header.
      ndisc: Introduce struct red_msg for redirect message.
      ndisc: Introduce ndisc_fill_redirect_hdr_option().
      ndisc: Rename and break up __ndisc_send().
      ndisc: Introduce ndisc_send_skb_alloc() for sk_buff allocation.
      ipv6: Move ip6_nd_hdr() to its users' source files.
      ndisc: Set skb->dev and skb->protocol inside ndisc_alloc_skb().
      ndisc: Defer building IPv6 header.
      ndisc: Reset skb->transport_header inside ndisc_alloc_send_skb().
      ndisc: Calculate message body length and option length separately.
      ndisc: Make ndisc_fill_xxx_option() for sk_buff.
      ndisc: Calculate checksum and build IPv6 header in __ndisc_send().
      ndisc: Concentrate ndisc_send() on sending message.
      ndisc: Break down ndisc_build_skb().
      ndisc: Fill in ND message on skb directly.
      ndisc: Use return value of __skb_put(), instead of icmp6_hdr().

[DIFFSTAT]
 include/net/ipv6.h    |   22 ++-
 include/net/ndisc.h   |    7 +
 net/ipv6/ip6_gre.c    |   18 +--
 net/ipv6/ip6_output.c |   51 +-------
 net/ipv6/ip6_tunnel.c |   12 +-
 net/ipv6/mcast.c      |   24 +++-
 net/ipv6/ndisc.c      |  326
+++++++++++++++++++++++++------------------------
 net/ipv6/route.c      |   24 ++--
 8 files changed, 234 insertions(+), 250 deletions(-)
