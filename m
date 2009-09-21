From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 02/13] TProxy: add lookup type checks for UDP in
 nf_tproxy_get_sock_v4()
Date: Mon, 21 Sep 2009 23:20:54 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0909212320150.31023@obet.zrqbmnf.qr>
References: <1253548005.12519.2.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:58748 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbZIUVUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 17:20:51 -0400
In-Reply-To: <1253548005.12519.2.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Saturday 2009-08-15 14:01, Balazs Scheidler wrote:

>+	case IPPROTO_UDP:
>+		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
>+				     in->ifindex);

You might want to add IPPROTO_UDPLITE in all places.

