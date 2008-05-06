From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: A question about setting the net device for multicast forwarding in IPv4 and in IPv6
Date: Tue, 6 May 2008 16:38:04 +0300
Message-ID: <31436f4a0805060638o2f97e3d7v8355fb678454da47@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	"=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:17404 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258AbYEFNiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 09:38:07 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1363386waf.23
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 06:38:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  I had noticed that in IPV4 we set the net device for multicast
forwarding in case
it is not already configured so, when the user space app calls
setsockopt() with MRT_INIT;
this is done by calling IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)++;
in ip_mroute_setsockopt(); (net/ipv4/ipmr.c).

On the other hand, the parallel method in IPv6 does **not** performs
such action, as can be seen
from ip6_mroute_setsockopt() in net/ipv6/ip6mr.c.

My question is : is there any special for it to be so? (In case it
should be also in IPv6, I will happy to send such a patch).

Best Regards,
DS
