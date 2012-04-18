From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/2] l2tp: Introduce L2TPv3 IP encapsulation
 support for IPv6
Date: Wed, 18 Apr 2012 00:28:20 -0400 (EDT)
Message-ID: <20120418.002820.1941255513481211357.davem@davemloft.net>
References: <y>
	<1334665766-11461-3-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696Ab2DRE22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 00:28:28 -0400
In-Reply-To: <1334665766-11461-3-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 17 Apr 2012 13:29:26 +0100

> L2TPv3 defines an IP encapsulation packet format where data is carried
> directly over IP (no UDP). The kernel already has support for L2TP IP
> encapsulation over IPv4 (l2tp_ip). This patch introduces support for L2TP
> IP encapsulation over IPv6.

Either the ipv4 side should be changed to use ip4_datagram_connect()
or the ipv6 side should duplicate just the parts of
ip6_datagram_connect() it needs.

Which is it? :-)
