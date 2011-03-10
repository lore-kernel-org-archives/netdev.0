From: Patrick Schaaf <netdev@bof.de>
Subject: 2.6.38-rc8 build failure - bridge vs. ipv6
Date: Thu, 10 Mar 2011 11:07:53 +0100
Message-ID: <1299751673.4109.23.camel@lat1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bof-2.saar.de ([192.109.53.146]:56389 "EHLO oknodo.bof.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147Ab1CJKtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 05:49:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I see a build / link failure:

net/built-in.o: In function `br_ip6_multicast_alloc_query':
/usr/src/linux-2.6.38-rc8/net/bridge/br_multicast.c:448: undefined
reference to `ipv6_dev_get_saddr'

This happens with bridging build-in and ipv6 modular.

The call to ipv6_dev_get_saddr was introduced there between 2.6.38-rc6
and 2.6.38-rc8, the -rc6 built just fine with the same .config

I work around it by making bridge build modular, but you might want to
fix it properly before releasing 2.6.38.

best regards
  Patrick

