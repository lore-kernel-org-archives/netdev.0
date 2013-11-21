From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Question about IPv6 neighbor discovery and 6lowpan
Date: Thu, 21 Nov 2013 17:02:58 +0200
Message-ID: <1385046178.2723.17.camel@jrissane-mobl.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10463 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068Ab3KUPDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 10:03:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am investigating RFC 6775 (Neighbor Discovery Optimization for IPv6
over Low-Power Wireless Personal Area Networks (6LoWPANs))
http://tools.ietf.org/html/rfc6775

The RFC suggests some changes to neighbor discovery procedure for the
6LoWPAN networks. I was looking net/ipv6/ndisc.c and it seems that
ARPHRD type (from type field in net_device struct) is the only way to
detect and change the discovery procedure in the ndisc.c code. Am I
right with this assumption here?


Cheers,
Jukka
